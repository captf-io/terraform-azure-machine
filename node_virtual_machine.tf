# Copyright 2026 The CAPTF Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# The node: one Linux VM (DESIGN.md decision 6). Name and hostname are the
# Machine's name, which cloud-provider-azure needs to find the VM from its
# Node (README "provider_id").
resource "azurerm_linux_virtual_machine" "node_virtual_machine" {
  count = local.exports_available ? 1 : 0

  admin_username = local.admin_username
  # No VM extensions: nothing here needs one, and each is code running as root.
  allow_extension_operations      = false
  availability_set_id             = local.availability_set_id
  computer_name                   = local.vm_name
  custom_data                     = local.custom_data
  disable_password_authentication = true
  encryption_at_host_enabled      = var.encryption_at_host
  eviction_policy                 = var.spot ? "Deallocate" : null
  location                        = local.location
  # -1: pay up to the on-demand price; Azure then evicts for capacity only.
  max_bid_price         = var.spot ? -1 : null
  name                  = local.vm_name
  network_interface_ids = [azurerm_network_interface.node_network_interface[0].id]
  priority              = var.spot ? "Spot" : "Regular"
  provision_vm_agent    = true
  resource_group_name   = local.resource_group_name
  secure_boot_enabled   = var.trusted_launch
  size                  = var.vm_size
  source_image_id       = local.image_id
  tags                  = local.tags
  vtpm_enabled          = var.trusted_launch
  zone                  = local.zone

  admin_ssh_key {
    public_key = local.admin_ssh_public_key
    username   = local.admin_username
  }

  # Azure-managed storage: no storage account to bring.
  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics ? [true] : []

    content {}
  }

  identity {
    identity_ids = [local.identity_id]
    type         = "UserAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    disk_size_gb         = var.os_disk_size_gib
    name                 = local.os_disk_name
    storage_account_type = var.os_disk_storage_account_type
  }

  lifecycle {
    # Checks that span variables (CONVENTIONS.md section 4).
    precondition {
      condition     = var.failure_domain == null || contains(local.failure_domain_names, coalesce(var.failure_domain, "-"))
      error_message = "failure_domain ${coalesce(var.failure_domain, "-")} is not a failure domain of the cluster (${length(local.failure_domain_names) > 0 ? join(", ", local.failure_domain_names) : "none: the region has no availability zones"})."
    }
    precondition {
      condition     = !local.image_uses_kubernetes_version || local.kubernetes_semver != null
      error_message = "image_id contains {version} or {semver}, but the Machine has no spec.version: set the version, or a fixed image_id."
    }
    precondition {
      condition     = !(var.spot && var.control_plane)
      error_message = "spot cannot be set for a control-plane machine: an eviction takes an etcd member away (CONVENTIONS.md section 11)."
    }
    precondition {
      condition     = !(var.bootstrap_format == "ignition" && local.bootstrap_gzipped)
      error_message = "bootstrap_data is gzipped Ignition, which this module rejects (CONVENTIONS.md section 13): turn off gzipUserData for Ignition."
    }
    precondition {
      # The values reach a root shell script on the node: only an IPv4
      # address and port numbers may.
      # try(): HCL evaluates both sides of ||, and api is null without the
      # workaround.
      condition = !local.apiserver_hairpin || try(
        can(regex("^((25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])$", local.api.frontend_ip)) &&
        alltrue([for p in [local.api.port, local.api.backend_port, coalesce(local.api.supervisor_port, 1)] : p == floor(p) && p >= 1 && p <= 65535]),
        false,
      )
      error_message = "exports.api must hold an IPv4 frontend_ip and port, backend_port and supervisor_port from 1 to 65535: check external_cluster_exports."
    }
    precondition {
      condition     = length(local.custom_data) <= local.custom_data_max_length
      error_message = "The custom data is ${nonsensitive(length(local.custom_data))} base64 characters, more than Azure's ${local.custom_data_max_length} (64 KiB): compress the bootstrap data (CAPRKE2 gzipUserData) or make it smaller."
    }
  }

  # The NIC must be in its security groups, and a control-plane NIC in the
  # API backend pool, before the VM boots and runs kubeadm: the VM itself
  # references none of the association resources.
  depends_on = [
    azurerm_network_interface_application_security_group_association.node_application_security_group_association,
    azurerm_network_interface_backend_address_pool_association.api_backend_pool_association,
    azurerm_network_interface_security_group_association.node_security_group_association,
  ]
}
