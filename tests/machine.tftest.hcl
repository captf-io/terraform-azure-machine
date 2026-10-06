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

# Unit tests of the machine role with a mocked azurerm provider: nothing
# reaches Azure. Run with `make unit-test` (terraform test and tofu test).

mock_provider "azurerm" {
  # IDs other resources take as arguments are pinned in ARM format: the
  # provider validates them even when mocked.
  mock_resource "azurerm_network_interface" {
    defaults = {
      id                 = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/networkInterfaces/demo-control-plane-x7k2p-nic"
      private_ip_address = "10.0.0.4"
    }
  }

  # The listing finds the VM and the status read reports it running, unless a
  # run overrides them.
  mock_data "azurerm_resources" {
    defaults = {
      resources = [{
        id                  = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Compute/virtualMachines/demo-control-plane-x7k2p"
        location            = "westeurope"
        name                = "demo-control-plane-x7k2p"
        resource_group_name = "captf-team-a-demo-2a8d5f7c"
        tags                = {}
        type                = "Microsoft.Compute/virtualMachines"
      }]
    }
  }

  mock_data "azurerm_virtual_machine" {
    defaults = {
      power_state        = "running"
      private_ip_address = "10.0.0.4"
    }
  }
}

variables {
  captf_contract = "v1alpha1"
  captf_cluster  = { name = "demo", namespace = "team-a" }
  captf_object   = { kind = "TerraformMachine", name = "demo-control-plane-x7k2p", namespace = "team-a" }
  captf_cluster_outputs = {
    schema              = "captf.io/azure-cluster/v1"
    tenant_id           = "72f988bf-86f1-41af-91ab-2d7cd011db47"
    subscription_id     = "6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11"
    region              = "westeurope"
    resource_group_name = "captf-team-a-demo-2a8d5f7c"
    resource_group_id   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c"
    failure_domains     = { "1" = {}, "2" = {}, "3" = {} }
    virtual_network = {
      id                  = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub"
      name                = "hub"
      resource_group_name = "network"
    }
    subnet_id            = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub/subnets/nodes"
    subnet_name          = "nodes"
    worker_subnet_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub/subnets/workers"
    worker_subnet_name   = "workers"
    admin_username       = "captf"
    admin_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0wmN/Cr3JXqmLW7u+g9pTh+wyqDHpSQEIQczXkVx9q captf@example"
    control_plane = {
      identity_id                   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.ManagedIdentity/userAssignedIdentities/captf-team-a-demo-2a8d5f7c-control-plane"
      identity_client_id            = "5e2f7a5b-0c6d-4e1f-9a2b-5c6d7e8f9a0b"
      network_security_group_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/networkSecurityGroups/captf-team-a-demo-2a8d5f7c-control-plane-nsg"
      network_security_group_name   = "captf-team-a-demo-2a8d5f7c-control-plane-nsg"
      application_security_group_id = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/applicationSecurityGroups/captf-team-a-demo-2a8d5f7c-control-plane-asg"
      availability_set_id           = null
    }
    worker = {
      identity_id                   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.ManagedIdentity/userAssignedIdentities/captf-team-a-demo-2a8d5f7c-worker"
      identity_client_id            = "7a4b9c7d-2e8f-4a3b-9c4d-7e8f9a0b1c2d"
      network_security_group_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/networkSecurityGroups/captf-team-a-demo-2a8d5f7c-worker-nsg"
      network_security_group_name   = "captf-team-a-demo-2a8d5f7c-worker-nsg"
      application_security_group_id = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/applicationSecurityGroups/captf-team-a-demo-2a8d5f7c-worker-asg"
    }
    api = {
      host               = "10.0.0.100"
      port               = 6443
      backend_port       = 6443
      frontend_ip        = "10.0.0.100"
      backend_pool_id    = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/loadBalancers/captf-team-a-demo-2a8d5f7c-api/backendAddressPools/control-plane"
      hairpin_workaround = true
      supervisor_port    = null
    }
    cloud_provider_config = {
      cloud                        = "AzurePublicCloud"
      tenantId                     = "72f988bf-86f1-41af-91ab-2d7cd011db47"
      subscriptionId               = "6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11"
      resourceGroup                = "captf-team-a-demo-2a8d5f7c"
      location                     = "westeurope"
      vmType                       = "vmss"
      vnetName                     = "hub"
      vnetResourceGroup            = "network"
      subnetName                   = "workers"
      securityGroupName            = "captf-team-a-demo-2a8d5f7c-worker-nsg"
      securityGroupResourceGroup   = "captf-team-a-demo-2a8d5f7c"
      loadBalancerSku              = "Standard"
      maximumLoadBalancerRuleCount = 250
      useManagedIdentityExtension  = true
      useInstanceMetadata          = true
    }
  }

  captf_tags         = { "captf.io/cluster" = "demo", "captf.io/namespace" = "team-a", "captf.io/kind" = "TerraformMachine", "captf.io/name" = "demo-control-plane-x7k2p", "captf.io/managed-by" = "captf", "captf.io/template" = "demo-control-plane" }
  machine_name       = "demo-control-plane-x7k2p"
  bootstrap_data     = "IyMgdGVtcGxhdGU6IGppbmphCiNjbG91ZC1jb25maWcKcnVuY21kOiBbZWNobyBoZWxsb10K"
  bootstrap_format   = "cloud-config"
  failure_domain     = "2"
  kubernetes_version = "v1.34.1"
  control_plane      = true

  image_id = "/communityGalleries/ClusterAPI-f72ceb4f-5159-4c26-a0fe-2ea738f0d019/images/capi-ubun2-2404/versions/{semver}"
}

run "happy_path" {
  assert {
    condition     = output.provider_id == "azure:///subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Compute/virtualMachines/demo-control-plane-x7k2p"
    error_message = "provider_id must be the VM's ARM ID with the azure:// scheme and a lowercase resource group."
  }
  assert {
    condition     = output.addresses == [{ type = "InternalIP", address = "10.0.0.4" }, { type = "Hostname", address = "demo-control-plane-x7k2p" }]
    error_message = "addresses are the NIC's private address and the hostname."
  }
  assert {
    condition     = output.failure_domain == "2" && azurerm_linux_virtual_machine.node_virtual_machine[0].zone == "2"
    error_message = "The VM sits in the requested failure domain, which is its zone."
  }
  assert {
    condition     = output.interruptible == false
    error_message = "A regular VM is not interruptible."
  }
  assert {
    condition     = output.health.state == "running" && output.health.healthy && output.health.message == "Azure VM power state running" && length(output.health.reasons) == 0
    error_message = "A listed, running VM is healthy."
  }
  assert {
    condition     = output.virtual_machine_id == azurerm_linux_virtual_machine.node_virtual_machine[0].id && output.network_interface_id == azurerm_network_interface.node_network_interface[0].id
    error_message = "The extra outputs name the VM and the NIC."
  }
  assert {
    condition     = azurerm_linux_virtual_machine.node_virtual_machine[0].name == "demo-control-plane-x7k2p" && azurerm_linux_virtual_machine.node_virtual_machine[0].computer_name == "demo-control-plane-x7k2p"
    error_message = "VM name and hostname are the Machine's name."
  }
  assert {
    condition     = azurerm_linux_virtual_machine.node_virtual_machine[0].source_image_id == "/communityGalleries/ClusterAPI-f72ceb4f-5159-4c26-a0fe-2ea738f0d019/images/capi-ubun2-2404/versions/1.34.1"
    error_message = "{semver} in image_id becomes the version without the v."
  }
  assert {
    condition     = azurerm_linux_virtual_machine.node_virtual_machine[0].size == "Standard_D4s_v5" && azurerm_linux_virtual_machine.node_virtual_machine[0].os_disk[0].disk_size_gb == 128 && azurerm_linux_virtual_machine.node_virtual_machine[0].os_disk[0].storage_account_type == "Premium_LRS"
    error_message = "The defaults are a Standard_D4s_v5 with a 128 GiB premium OS disk."
  }
  assert {
    condition     = azurerm_linux_virtual_machine.node_virtual_machine[0].disable_password_authentication && !azurerm_linux_virtual_machine.node_virtual_machine[0].allow_extension_operations && azurerm_linux_virtual_machine.node_virtual_machine[0].admin_username == "captf"
    error_message = "Password login and extensions are off; the admin user comes from exports."
  }
  assert {
    condition     = toset(azurerm_linux_virtual_machine.node_virtual_machine[0].identity[0].identity_ids) == toset([var.captf_cluster_outputs.control_plane.identity_id])
    error_message = "A control-plane VM runs as the control-plane identity."
  }
  assert {
    condition     = azurerm_network_interface.node_network_interface[0].ip_configuration[0].subnet_id == var.captf_cluster_outputs.subnet_id && azurerm_network_interface.node_network_interface[0].accelerated_networking_enabled && !azurerm_network_interface.node_network_interface[0].ip_forwarding_enabled
    error_message = "A control-plane NIC sits in the control-plane subnet, accelerated, without IP forwarding."
  }
  assert {
    condition     = azurerm_network_interface_security_group_association.node_security_group_association[0].network_security_group_id == var.captf_cluster_outputs.control_plane.network_security_group_id && azurerm_network_interface_application_security_group_association.node_application_security_group_association[0].application_security_group_id == var.captf_cluster_outputs.control_plane.application_security_group_id
    error_message = "A control-plane NIC joins the control-plane security group and application security group."
  }
  assert {
    condition     = azurerm_linux_virtual_machine.node_virtual_machine[0].availability_set_id == null && length(azurerm_linux_virtual_machine.node_virtual_machine[0].boot_diagnostics) == 0
    error_message = "A zonal VM has no availability set; boot diagnostics are off by default."
  }
}

run "reapply_is_stable" {
  variables {
    previous_virtual_machine_id   = run.happy_path.virtual_machine_id
    previous_network_interface_id = run.happy_path.network_interface_id
    previous_provider_id          = run.happy_path.provider_id
  }

  assert {
    condition     = output.virtual_machine_id == var.previous_virtual_machine_id && output.network_interface_id == var.previous_network_interface_id && output.provider_id == var.previous_provider_id
    error_message = "A second identical apply must keep the VM and its NIC."
  }
}

run "tags_on_taggable_resources" {
  variables {
    additional_tags = { costCenter = "1234" }
  }

  assert {
    condition = alltrue([
      for t in [azurerm_linux_virtual_machine.node_virtual_machine[0].tags, azurerm_network_interface.node_network_interface[0].tags] :
      t["captf.io_cluster"] == "demo" && t["captf.io_kind"] == "TerraformMachine" && t["captf.io_name"] == "demo-control-plane-x7k2p" && t["captf.io_template"] == "demo-control-plane" && t["costCenter"] == "1234"
    ])
    error_message = "The VM and its NIC carry the mapped captf tags and the additional tags."
  }
}

run "control_plane_registers_backend" {
  assert {
    condition     = length(azurerm_network_interface_backend_address_pool_association.api_backend_pool_association) == 1 && azurerm_network_interface_backend_address_pool_association.api_backend_pool_association[0].backend_address_pool_id == var.captf_cluster_outputs.api.backend_pool_id && azurerm_network_interface_backend_address_pool_association.api_backend_pool_association[0].ip_configuration_name == "primary"
    error_message = "A control-plane NIC joins the API backend pool in the machine's own state."
  }
  assert {
    condition     = strcontains(nonsensitive(base64decode(azurerm_linux_virtual_machine.node_virtual_machine[0].custom_data)), "systemd-run --no-block --unit=captf-apiserver-hairpin") && strcontains(nonsensitive(base64decode(azurerm_linux_virtual_machine.node_virtual_machine[0].custom_data)), "frontend_ip='10.0.0.100'")
    error_message = "A control-plane VM gets the API server hairpin workaround for the frontend address."
  }
}

run "worker_has_no_backend" {
  variables {
    machine_name   = "demo-md-0-8f5c7-k2x9z"
    control_plane  = false
    failure_domain = null
  }

  assert {
    condition     = length(azurerm_network_interface_backend_address_pool_association.api_backend_pool_association) == 0
    error_message = "A worker does not join the API backend pool."
  }
  assert {
    condition     = !strcontains(nonsensitive(base64decode(azurerm_linux_virtual_machine.node_virtual_machine[0].custom_data)), "captf-apiserver-hairpin")
    error_message = "A worker gets no hairpin workaround."
  }
  assert {
    condition     = azurerm_network_interface.node_network_interface[0].ip_configuration[0].subnet_id == var.captf_cluster_outputs.worker_subnet_id && azurerm_network_interface_security_group_association.node_security_group_association[0].network_security_group_id == var.captf_cluster_outputs.worker.network_security_group_id
    error_message = "A worker uses the worker subnet and security group."
  }
  assert {
    condition     = toset(azurerm_linux_virtual_machine.node_virtual_machine[0].identity[0].identity_ids) == toset([var.captf_cluster_outputs.worker.identity_id])
    error_message = "A worker runs as the worker identity."
  }
  assert {
    condition     = strcontains(nonsensitive(base64decode(azurerm_linux_virtual_machine.node_virtual_machine[0].custom_data)), "\"userAssignedIdentityID\":\"7a4b9c7d-2e8f-4a3b-9c4d-7e8f9a0b1c2d\"")
    error_message = "A worker's cloud provider config names the worker identity."
  }
}

run "user_endpoint_has_no_backend" {
  variables {
    captf_cluster_outputs = {
      schema              = "captf.io/azure-cluster/v1"
      tenant_id           = "72f988bf-86f1-41af-91ab-2d7cd011db47"
      subscription_id     = "6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11"
      region              = "westeurope"
      resource_group_name = "captf-team-a-demo-2a8d5f7c"
      resource_group_id   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c"
      failure_domains     = { "1" = {}, "2" = {}, "3" = {} }
      virtual_network = {
        id                  = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub"
        name                = "hub"
        resource_group_name = "network"
      }
      subnet_id            = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub/subnets/nodes"
      subnet_name          = "nodes"
      worker_subnet_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub/subnets/workers"
      worker_subnet_name   = "workers"
      admin_username       = "captf"
      admin_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0wmN/Cr3JXqmLW7u+g9pTh+wyqDHpSQEIQczXkVx9q captf@example"
      control_plane = {
        identity_id                   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.ManagedIdentity/userAssignedIdentities/captf-team-a-demo-2a8d5f7c-control-plane"
        identity_client_id            = "5e2f7a5b-0c6d-4e1f-9a2b-5c6d7e8f9a0b"
        network_security_group_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/networkSecurityGroups/captf-team-a-demo-2a8d5f7c-control-plane-nsg"
        network_security_group_name   = "captf-team-a-demo-2a8d5f7c-control-plane-nsg"
        application_security_group_id = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/applicationSecurityGroups/captf-team-a-demo-2a8d5f7c-control-plane-asg"
        availability_set_id           = null
      }
      worker = {
        identity_id                   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.ManagedIdentity/userAssignedIdentities/captf-team-a-demo-2a8d5f7c-worker"
        identity_client_id            = "7a4b9c7d-2e8f-4a3b-9c4d-7e8f9a0b1c2d"
        network_security_group_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/networkSecurityGroups/captf-team-a-demo-2a8d5f7c-worker-nsg"
        network_security_group_name   = "captf-team-a-demo-2a8d5f7c-worker-nsg"
        application_security_group_id = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/applicationSecurityGroups/captf-team-a-demo-2a8d5f7c-worker-asg"
      }
      api = null
      cloud_provider_config = {
        cloud                        = "AzurePublicCloud"
        tenantId                     = "72f988bf-86f1-41af-91ab-2d7cd011db47"
        subscriptionId               = "6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11"
        resourceGroup                = "captf-team-a-demo-2a8d5f7c"
        location                     = "westeurope"
        vmType                       = "vmss"
        vnetName                     = "hub"
        vnetResourceGroup            = "network"
        subnetName                   = "workers"
        securityGroupName            = "captf-team-a-demo-2a8d5f7c-worker-nsg"
        securityGroupResourceGroup   = "captf-team-a-demo-2a8d5f7c"
        loadBalancerSku              = "Standard"
        maximumLoadBalancerRuleCount = 250
        useManagedIdentityExtension  = true
        useInstanceMetadata          = true
      }
    }
  }


  assert {
    condition     = length(azurerm_network_interface_backend_address_pool_association.api_backend_pool_association) == 0 && !strcontains(nonsensitive(base64decode(azurerm_linux_virtual_machine.node_virtual_machine[0].custom_data)), "captf-apiserver-hairpin")
    error_message = "With a user endpoint there is no backend pool to join and no hairpin."
  }
}

run "failure_domain_requested" {
  variables {
    failure_domain = "3"
  }

  assert {
    condition     = output.failure_domain == "3" && azurerm_linux_virtual_machine.node_virtual_machine[0].zone == "3"
    error_message = "A requested failure domain is the VM's zone and the output."
  }
}

run "failure_domain_defaulted" {
  variables {
    failure_domain = null
  }

  assert {
    condition     = output.failure_domain == ["1", "2", "3"][parseint(substr(sha256("demo-control-plane-x7k2p"), 0, 8), 16) % 3]
    error_message = "Without a request, the zone is picked from the sha256 of machine_name over the sorted failure domains."
  }
  assert {
    condition     = azurerm_linux_virtual_machine.node_virtual_machine[0].zone == output.failure_domain
    error_message = "The picked failure domain is the VM's zone."
  }
}

run "region_without_zones" {
  variables {
    failure_domain = null
    captf_cluster_outputs = {
      schema              = "captf.io/azure-cluster/v1"
      tenant_id           = "72f988bf-86f1-41af-91ab-2d7cd011db47"
      subscription_id     = "6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11"
      region              = "westeurope"
      resource_group_name = "captf-team-a-demo-2a8d5f7c"
      resource_group_id   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c"
      failure_domains     = {}
      virtual_network = {
        id                  = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub"
        name                = "hub"
        resource_group_name = "network"
      }
      subnet_id            = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub/subnets/nodes"
      subnet_name          = "nodes"
      worker_subnet_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub/subnets/workers"
      worker_subnet_name   = "workers"
      admin_username       = "captf"
      admin_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0wmN/Cr3JXqmLW7u+g9pTh+wyqDHpSQEIQczXkVx9q captf@example"
      control_plane = {
        identity_id                   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.ManagedIdentity/userAssignedIdentities/captf-team-a-demo-2a8d5f7c-control-plane"
        identity_client_id            = "5e2f7a5b-0c6d-4e1f-9a2b-5c6d7e8f9a0b"
        network_security_group_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/networkSecurityGroups/captf-team-a-demo-2a8d5f7c-control-plane-nsg"
        network_security_group_name   = "captf-team-a-demo-2a8d5f7c-control-plane-nsg"
        application_security_group_id = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/applicationSecurityGroups/captf-team-a-demo-2a8d5f7c-control-plane-asg"
        availability_set_id           = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Compute/availabilitySets/captf-team-a-demo-2a8d5f7c-control-plane"
      }
      worker = {
        identity_id                   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.ManagedIdentity/userAssignedIdentities/captf-team-a-demo-2a8d5f7c-worker"
        identity_client_id            = "7a4b9c7d-2e8f-4a3b-9c4d-7e8f9a0b1c2d"
        network_security_group_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/networkSecurityGroups/captf-team-a-demo-2a8d5f7c-worker-nsg"
        network_security_group_name   = "captf-team-a-demo-2a8d5f7c-worker-nsg"
        application_security_group_id = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/applicationSecurityGroups/captf-team-a-demo-2a8d5f7c-worker-asg"
      }
      api = {
        host               = "10.0.0.100"
        port               = 6443
        backend_port       = 6443
        frontend_ip        = "10.0.0.100"
        backend_pool_id    = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/loadBalancers/captf-team-a-demo-2a8d5f7c-api/backendAddressPools/control-plane"
        hairpin_workaround = true
        supervisor_port    = null
      }
      cloud_provider_config = {
        cloud                        = "AzurePublicCloud"
        tenantId                     = "72f988bf-86f1-41af-91ab-2d7cd011db47"
        subscriptionId               = "6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11"
        resourceGroup                = "captf-team-a-demo-2a8d5f7c"
        location                     = "westeurope"
        vmType                       = "vmss"
        vnetName                     = "hub"
        vnetResourceGroup            = "network"
        subnetName                   = "workers"
        securityGroupName            = "captf-team-a-demo-2a8d5f7c-worker-nsg"
        securityGroupResourceGroup   = "captf-team-a-demo-2a8d5f7c"
        loadBalancerSku              = "Standard"
        maximumLoadBalancerRuleCount = 250
        useManagedIdentityExtension  = true
        useInstanceMetadata          = true
      }
    }
  }

  assert {
    condition     = output.failure_domain == null && azurerm_linux_virtual_machine.node_virtual_machine[0].zone == null
    error_message = "Without zones there is no failure domain."
  }
  assert {
    condition     = endswith(azurerm_linux_virtual_machine.node_virtual_machine[0].availability_set_id, "/availabilitySets/captf-team-a-demo-2a8d5f7c-control-plane")
    error_message = "Without zones a control-plane VM joins the availability set."
  }
}

run "unknown_failure_domain" {
  command = plan

  variables {
    failure_domain = "4"
  }

  expect_failures = [azurerm_linux_virtual_machine.node_virtual_machine]
}

run "boot_diagnostics_opt_in" {
  variables {
    boot_diagnostics = true
  }

  assert {
    condition     = length(azurerm_linux_virtual_machine.node_virtual_machine[0].boot_diagnostics) == 1
    error_message = "boot_diagnostics = true turns the serial console log on."
  }
}

run "spot_is_interruptible" {
  variables {
    spot          = true
    control_plane = false
  }

  assert {
    condition     = output.interruptible == true && azurerm_linux_virtual_machine.node_virtual_machine[0].priority == "Spot" && azurerm_linux_virtual_machine.node_virtual_machine[0].eviction_policy == "Deallocate" && azurerm_linux_virtual_machine.node_virtual_machine[0].max_bid_price == -1
    error_message = "A Spot VM is deallocated on eviction, capped at the on-demand price and interruptible."
  }
}

run "externally_managed_without_override" {
  command = plan

  variables {
    captf_cluster_outputs = {}
  }

  expect_failures = [data.azurerm_resources.node_virtual_machine_listing]
}

run "externally_managed_with_override" {
  variables {
    captf_cluster_outputs = {}
    external_cluster_exports = {
      schema              = "captf.io/azure-cluster/v1"
      tenant_id           = "72f988bf-86f1-41af-91ab-2d7cd011db47"
      subscription_id     = "6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11"
      region              = "northeurope"
      resource_group_name = "captf-team-a-demo-2a8d5f7c"
      resource_group_id   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c"
      failure_domains     = { "1" = {}, "2" = {}, "3" = {} }
      virtual_network = {
        id                  = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub"
        name                = "hub"
        resource_group_name = "network"
      }
      subnet_id            = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub/subnets/nodes"
      subnet_name          = "nodes"
      worker_subnet_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub/subnets/workers"
      worker_subnet_name   = "workers"
      admin_username       = "captf"
      admin_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0wmN/Cr3JXqmLW7u+g9pTh+wyqDHpSQEIQczXkVx9q captf@example"
      control_plane = {
        identity_id                   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.ManagedIdentity/userAssignedIdentities/captf-team-a-demo-2a8d5f7c-control-plane"
        identity_client_id            = "5e2f7a5b-0c6d-4e1f-9a2b-5c6d7e8f9a0b"
        network_security_group_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/networkSecurityGroups/captf-team-a-demo-2a8d5f7c-control-plane-nsg"
        network_security_group_name   = "captf-team-a-demo-2a8d5f7c-control-plane-nsg"
        application_security_group_id = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/applicationSecurityGroups/captf-team-a-demo-2a8d5f7c-control-plane-asg"
        availability_set_id           = null
      }
      worker = {
        identity_id                   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.ManagedIdentity/userAssignedIdentities/captf-team-a-demo-2a8d5f7c-worker"
        identity_client_id            = "7a4b9c7d-2e8f-4a3b-9c4d-7e8f9a0b1c2d"
        network_security_group_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/networkSecurityGroups/captf-team-a-demo-2a8d5f7c-worker-nsg"
        network_security_group_name   = "captf-team-a-demo-2a8d5f7c-worker-nsg"
        application_security_group_id = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/applicationSecurityGroups/captf-team-a-demo-2a8d5f7c-worker-asg"
      }
      api = {
        host               = "10.0.0.100"
        port               = 6443
        backend_port       = 6443
        frontend_ip        = "10.0.0.100"
        backend_pool_id    = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/loadBalancers/captf-team-a-demo-2a8d5f7c-api/backendAddressPools/control-plane"
        hairpin_workaround = true
        supervisor_port    = null
      }
      cloud_provider_config = {
        cloud                        = "AzurePublicCloud"
        tenantId                     = "72f988bf-86f1-41af-91ab-2d7cd011db47"
        subscriptionId               = "6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11"
        resourceGroup                = "captf-team-a-demo-2a8d5f7c"
        location                     = "westeurope"
        vmType                       = "vmss"
        vnetName                     = "hub"
        vnetResourceGroup            = "network"
        subnetName                   = "workers"
        securityGroupName            = "captf-team-a-demo-2a8d5f7c-worker-nsg"
        securityGroupResourceGroup   = "captf-team-a-demo-2a8d5f7c"
        loadBalancerSku              = "Standard"
        maximumLoadBalancerRuleCount = 250
        useManagedIdentityExtension  = true
        useInstanceMetadata          = true
      }
    }
  }

  assert {
    condition     = azurerm_linux_virtual_machine.node_virtual_machine[0].location == "northeurope" && output.provider_id == "azure:///subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Compute/virtualMachines/demo-control-plane-x7k2p"
    error_message = "external_cluster_exports stands in for the exports of an externally managed cluster."
  }
}

run "wrong_exports_schema" {
  command = plan

  variables {
    captf_cluster_outputs = { schema = "captf.io/aws-cluster/v1" }
  }

  expect_failures = [var.captf_cluster_outputs]
}

run "bootstrap_cloud_config" {
  assert {
    condition     = startswith(nonsensitive(base64decode(azurerm_linux_virtual_machine.node_virtual_machine[0].custom_data)), "Content-Type: multipart/mixed; boundary=\"==CAPTF-BOUNDARY==\"\nMIME-Version: 1.0\n")
    error_message = "cloud-config custom data is a MIME multipart."
  }
  assert {
    condition     = strcontains(nonsensitive(base64decode(azurerm_linux_virtual_machine.node_virtual_machine[0].custom_data)), "Content-Type: text/plain; charset=\"utf-8\"\nMIME-Version: 1.0\nContent-Transfer-Encoding: base64\nContent-Disposition: attachment; filename=\"bootstrap\"\n\nIyMgdGVtcGxhdGU6IGppbmphCiNjbG91ZC1jb25maWcKcnVuY21kOiBbZWNobyBoZWxsb10K\n--==CAPTF-BOUNDARY==--")
    error_message = "The bootstrap data is an opaque base64 text/plain part, so cloud-init detects its jinja header itself."
  }
  assert {
    condition     = strcontains(nonsensitive(base64decode(azurerm_linux_virtual_machine.node_virtual_machine[0].custom_data)), "Content-Type: text/cloud-boothook") && strcontains(nonsensitive(base64decode(azurerm_linux_virtual_machine.node_virtual_machine[0].custom_data)), "cat > /etc/kubernetes/azure.json <<'CAPTF_EOF'\n{\"cloud\":\"AzurePublicCloud\"")
    error_message = "The boothook writes the cloud provider config."
  }
  assert {
    condition     = strcontains(nonsensitive(base64decode(azurerm_linux_virtual_machine.node_virtual_machine[0].custom_data)), "\"userAssignedIdentityID\":\"5e2f7a5b-0c6d-4e1f-9a2b-5c6d7e8f9a0b\"")
    error_message = "The cloud provider config names the control-plane identity."
  }
}

run "bootstrap_cloud_config_gzip" {
  variables {
    bootstrap_data = "H4sIAAAAAAAC/0XMuQ2AMAwAwD5TWKIlC7AKSmFi55GcOMpTwPTQMcDd5kUXWa815Gj6qr7QYSyc7JPukFhEIXQtgBCf3BoTXKpzzI4NGt6iSO4Hg7+KQHJlZ15cX5g2XQAAAA=="
  }

  assert {
    condition     = strcontains(nonsensitive(base64decode(azurerm_linux_virtual_machine.node_virtual_machine[0].custom_data)), "Content-Type: application/x-gzip\nMIME-Version: 1.0\nContent-Transfer-Encoding: base64\nContent-Disposition: attachment; filename=\"bootstrap\"\n\nH4sIAAAAAAAC/0XMuQ2AMAwAwD5TWKIlC7AKSmFi55GcOMpTwPTQMcDd5kUXWa815Gj6qr7QYSyc\n7JPukFhEIXQtgBCf3BoTXKpzzI4NGt6iSO4Hg7+KQHJlZ15cX5g2XQAAAA==\n--==CAPTF")
    error_message = "A gzipped payload is an application/x-gzip part, never decoded, in 76-character lines."
  }
}

run "bootstrap_ignition" {
  variables {
    bootstrap_format = "ignition"
    bootstrap_data   = "eyJpZ25pdGlvbiI6eyJ2ZXJzaW9uIjoiMy40LjAifX0="
  }

  assert {
    condition     = nonsensitive(azurerm_linux_virtual_machine.node_virtual_machine[0].custom_data) == "eyJpZ25pdGlvbiI6eyJ2ZXJzaW9uIjoiMy40LjAifX0="
    error_message = "Ignition is passed through unchanged."
  }
}

run "bootstrap_too_large" {
  command = plan

  variables {
    bootstrap_data = base64encode(format("%070000d", 0))
  }

  expect_failures = [azurerm_linux_virtual_machine.node_virtual_machine]
}

run "long_machine_name" {
  variables {
    machine_name = "a-very-long-machine-deployment-name-for-team-a.workers-7d9f8c6b5d-x2k4p"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.node_virtual_machine[0].name == "a-very-long-machine-deployment-name-for-team-a-workers-${substr(sha256("a-very-long-machine-deployment-name-for-team-a.workers-7d9f8c6b5d-x2k4p"), 0, 8)}"
    error_message = "A name Azure does not accept is made valid, cut, and suffixed with its hash."
  }
  assert {
    condition     = length(azurerm_linux_virtual_machine.node_virtual_machine[0].name) <= 64 && azurerm_linux_virtual_machine.node_virtual_machine[0].computer_name == azurerm_linux_virtual_machine.node_virtual_machine[0].name
    error_message = "The VM name fits 64 characters and is the hostname."
  }
}

run "health_running" {
  assert {
    condition     = output.health.state == "running" && output.health.healthy && length(output.health.reasons) == 0
    error_message = "running -> running, healthy."
  }
}

run "health_pending" {
  override_data {
    target = data.azurerm_virtual_machine.node_virtual_machine_status
    values = { power_state = "starting" }
  }

  assert {
    condition     = output.health.state == "pending" && !output.health.healthy && output.health.message == "Azure VM power state starting" && jsonencode(output.health.reasons) == jsonencode(["PowerState/starting"])
    error_message = "starting -> pending."
  }
}

run "health_no_power_state" {
  override_data {
    target = data.azurerm_virtual_machine.node_virtual_machine_status
    values = { power_state = "" }
  }

  assert {
    condition     = output.health.state == "pending" && !output.health.healthy && jsonencode(output.health.reasons) == jsonencode(["PowerState/unknown"])
    error_message = "No power state yet (still creating) -> pending."
  }
}

run "health_stopping" {
  override_data {
    target = data.azurerm_virtual_machine.node_virtual_machine_status
    values = { power_state = "stopping" }
  }

  assert {
    condition     = output.health.state == "stopped" && !output.health.healthy && jsonencode(output.health.reasons) == jsonencode(["PowerState/stopping"])
    error_message = "stopping -> stopped."
  }
}

run "health_stopped" {
  override_data {
    target = data.azurerm_virtual_machine.node_virtual_machine_status
    values = { power_state = "stopped" }
  }

  assert {
    condition     = output.health.state == "stopped" && !output.health.healthy
    error_message = "stopped -> stopped."
  }
}

run "health_deallocating" {
  override_data {
    target = data.azurerm_virtual_machine.node_virtual_machine_status
    values = { power_state = "deallocating" }
  }

  assert {
    condition     = output.health.state == "stopped" && !output.health.healthy
    error_message = "deallocating -> stopped."
  }
}

run "health_deallocated" {
  override_data {
    target = data.azurerm_virtual_machine.node_virtual_machine_status
    values = { power_state = "deallocated" }
  }

  assert {
    condition     = output.health.state == "stopped" && !output.health.healthy && output.health.message == "Azure VM power state deallocated" && jsonencode(output.health.reasons) == jsonencode(["PowerState/deallocated"])
    error_message = "deallocated (a Spot eviction) -> stopped."
  }
}

run "health_unknown" {
  override_data {
    target = data.azurerm_virtual_machine.node_virtual_machine_status
    values = { power_state = "hibernated" }
  }

  assert {
    condition     = output.health.state == "unknown" && !output.health.healthy && jsonencode(output.health.reasons) == jsonencode(["UnknownState"])
    error_message = "A power state the module does not know -> unknown."
  }
}

run "health_not_listed" {
  override_data {
    target = data.azurerm_resources.node_virtual_machine_listing
    values = { resources = [] }
  }

  assert {
    condition     = output.health.state == "pending" && !output.health.healthy && output.health.message == "Azure VM demo-control-plane-x7k2p not listed yet" && jsonencode(output.health.reasons) == jsonencode(["VirtualMachineNotListed"])
    error_message = "A VM the listing does not show yet (the first apply) -> pending, without reading its status."
  }
  assert {
    condition     = length(data.azurerm_virtual_machine.node_virtual_machine_status) == 0
    error_message = "The status read is skipped when the listing does not show the VM, so a missing VM never fails a refresh."
  }
}

run "health_listed_in_other_group" {
  override_data {
    target = data.azurerm_resources.node_virtual_machine_listing
    values = {
      resources = [{
        id                  = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/other/providers/Microsoft.Compute/virtualMachines/demo-control-plane-x7k2p"
        location            = "westeurope"
        name                = "demo-control-plane-x7k2p"
        resource_group_name = "other"
        tags                = {}
        type                = "Microsoft.Compute/virtualMachines"
      }]
    }
  }

  # The listing is subscription-wide (a deleted resource group must not
  # fail it); a VM of the same name elsewhere is not this machine's.
  assert {
    condition     = output.health.state == "pending" && length(data.azurerm_virtual_machine.node_virtual_machine_status) == 0
    error_message = "Only a VM in the cluster's resource group counts."
  }
}

run "rejects_unsafe_exports_api" {
  command = plan

  variables {
    captf_cluster_outputs = {
      schema              = "captf.io/azure-cluster/v1"
      tenant_id           = "72f988bf-86f1-41af-91ab-2d7cd011db47"
      subscription_id     = "6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11"
      region              = "westeurope"
      resource_group_name = "captf-team-a-demo-2a8d5f7c"
      resource_group_id   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c"
      failure_domains     = { "1" = {}, "2" = {}, "3" = {} }
      virtual_network = {
        id                  = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub"
        name                = "hub"
        resource_group_name = "network"
      }
      subnet_id            = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub/subnets/nodes"
      subnet_name          = "nodes"
      worker_subnet_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub/subnets/workers"
      worker_subnet_name   = "workers"
      admin_username       = "captf"
      admin_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0wmN/Cr3JXqmLW7u+g9pTh+wyqDHpSQEIQczXkVx9q captf@example"
      control_plane = {
        identity_id                   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.ManagedIdentity/userAssignedIdentities/captf-team-a-demo-2a8d5f7c-control-plane"
        identity_client_id            = "5e2f7a5b-0c6d-4e1f-9a2b-5c6d7e8f9a0b"
        network_security_group_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/networkSecurityGroups/captf-team-a-demo-2a8d5f7c-control-plane-nsg"
        network_security_group_name   = "captf-team-a-demo-2a8d5f7c-control-plane-nsg"
        application_security_group_id = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/applicationSecurityGroups/captf-team-a-demo-2a8d5f7c-control-plane-asg"
        availability_set_id           = null
      }
      worker = {
        identity_id                   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.ManagedIdentity/userAssignedIdentities/captf-team-a-demo-2a8d5f7c-worker"
        identity_client_id            = "7a4b9c7d-2e8f-4a3b-9c4d-7e8f9a0b1c2d"
        network_security_group_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/networkSecurityGroups/captf-team-a-demo-2a8d5f7c-worker-nsg"
        network_security_group_name   = "captf-team-a-demo-2a8d5f7c-worker-nsg"
        application_security_group_id = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/applicationSecurityGroups/captf-team-a-demo-2a8d5f7c-worker-asg"
      }
      api = {
        host               = "10.0.0.100"
        port               = 6443
        backend_port       = 6443
        frontend_ip        = "10.0.0.100'; reboot; '"
        backend_pool_id    = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/loadBalancers/captf-team-a-demo-2a8d5f7c-api/backendAddressPools/control-plane"
        hairpin_workaround = true
        supervisor_port    = null
      }
      cloud_provider_config = {
        cloud                        = "AzurePublicCloud"
        tenantId                     = "72f988bf-86f1-41af-91ab-2d7cd011db47"
        subscriptionId               = "6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11"
        resourceGroup                = "captf-team-a-demo-2a8d5f7c"
        location                     = "westeurope"
        vmType                       = "vmss"
        vnetName                     = "hub"
        vnetResourceGroup            = "network"
        subnetName                   = "workers"
        securityGroupName            = "captf-team-a-demo-2a8d5f7c-worker-nsg"
        securityGroupResourceGroup   = "captf-team-a-demo-2a8d5f7c"
        loadBalancerSku              = "Standard"
        maximumLoadBalancerRuleCount = 250
        useManagedIdentityExtension  = true
        useInstanceMetadata          = true
      }
    }
  }

  expect_failures = [azurerm_linux_virtual_machine.node_virtual_machine]
}

run "rke2_hairpin_includes_supervisor" {
  variables {
    captf_cluster_outputs = {
      schema              = "captf.io/azure-cluster/v1"
      tenant_id           = "72f988bf-86f1-41af-91ab-2d7cd011db47"
      subscription_id     = "6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11"
      region              = "westeurope"
      resource_group_name = "captf-team-a-demo-2a8d5f7c"
      resource_group_id   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c"
      failure_domains     = { "1" = {}, "2" = {}, "3" = {} }
      virtual_network = {
        id                  = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub"
        name                = "hub"
        resource_group_name = "network"
      }
      subnet_id            = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub/subnets/nodes"
      subnet_name          = "nodes"
      worker_subnet_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/hub/subnets/workers"
      worker_subnet_name   = "workers"
      admin_username       = "captf"
      admin_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0wmN/Cr3JXqmLW7u+g9pTh+wyqDHpSQEIQczXkVx9q captf@example"
      control_plane = {
        identity_id                   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.ManagedIdentity/userAssignedIdentities/captf-team-a-demo-2a8d5f7c-control-plane"
        identity_client_id            = "5e2f7a5b-0c6d-4e1f-9a2b-5c6d7e8f9a0b"
        network_security_group_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/networkSecurityGroups/captf-team-a-demo-2a8d5f7c-control-plane-nsg"
        network_security_group_name   = "captf-team-a-demo-2a8d5f7c-control-plane-nsg"
        application_security_group_id = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/applicationSecurityGroups/captf-team-a-demo-2a8d5f7c-control-plane-asg"
        availability_set_id           = null
      }
      worker = {
        identity_id                   = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.ManagedIdentity/userAssignedIdentities/captf-team-a-demo-2a8d5f7c-worker"
        identity_client_id            = "7a4b9c7d-2e8f-4a3b-9c4d-7e8f9a0b1c2d"
        network_security_group_id     = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/networkSecurityGroups/captf-team-a-demo-2a8d5f7c-worker-nsg"
        network_security_group_name   = "captf-team-a-demo-2a8d5f7c-worker-nsg"
        application_security_group_id = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/applicationSecurityGroups/captf-team-a-demo-2a8d5f7c-worker-asg"
      }
      api = {
        host               = "10.0.0.100"
        port               = 6443
        backend_port       = 6443
        frontend_ip        = "10.0.0.100"
        backend_pool_id    = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/captf-team-a-demo-2a8d5f7c/providers/Microsoft.Network/loadBalancers/captf-team-a-demo-2a8d5f7c-api/backendAddressPools/control-plane"
        hairpin_workaround = true
        supervisor_port    = 9345
      }
      cloud_provider_config = {
        cloud                        = "AzurePublicCloud"
        tenantId                     = "72f988bf-86f1-41af-91ab-2d7cd011db47"
        subscriptionId               = "6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11"
        resourceGroup                = "captf-team-a-demo-2a8d5f7c"
        location                     = "westeurope"
        vmType                       = "vmss"
        vnetName                     = "hub"
        vnetResourceGroup            = "network"
        subnetName                   = "workers"
        securityGroupName            = "captf-team-a-demo-2a8d5f7c-worker-nsg"
        securityGroupResourceGroup   = "captf-team-a-demo-2a8d5f7c"
        loadBalancerSku              = "Standard"
        maximumLoadBalancerRuleCount = 250
        useManagedIdentityExtension  = true
        useInstanceMetadata          = true
      }
    }
  }

  assert {
    condition     = strcontains(nonsensitive(base64decode(azurerm_linux_virtual_machine.node_virtual_machine[0].custom_data)), "supervisor_port='9345'")
    error_message = "With RKE2 the hairpin also covers the supervisor port and accepts an API server without anonymous auth."
  }
}

run "rejects_unversioned_image" {
  command = plan

  variables {
    kubernetes_version = null
  }

  expect_failures = [azurerm_linux_virtual_machine.node_virtual_machine]
}

run "rke2_version_suffix" {
  variables {
    kubernetes_version = "v1.34.1+rke2r1"
  }

  assert {
    condition     = endswith(azurerm_linux_virtual_machine.node_virtual_machine[0].source_image_id, "/versions/1.34.1")
    error_message = "The +rke2rN suffix is stripped before the image lookup."
  }
}

run "rejects_spot_control_plane" {
  command = plan

  variables {
    spot = true
  }

  expect_failures = [azurerm_linux_virtual_machine.node_virtual_machine]
}

run "rejects_gzipped_ignition" {
  command = plan

  variables {
    bootstrap_format = "ignition"
    bootstrap_data   = "H4sIAAAAAAAC/6tWykzPyyzJzM9TsqpWKkstKgYzlYz1TPQMlGprAWys13sgAAAA"
  }

  expect_failures = [azurerm_linux_virtual_machine.node_virtual_machine]
}

run "image_version_placeholder" {
  command = plan

  variables {
    image_id = "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/images/providers/Microsoft.Compute/galleries/capi/images/ubuntu-{version}/versions/1.0.0"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.node_virtual_machine[0].source_image_id == "/subscriptions/6f1c1e1a-3b7e-4a3c-9a39-5d2f1c0b8e11/resourceGroups/images/providers/Microsoft.Compute/galleries/capi/images/ubuntu-v1.34.1/versions/1.0.0"
    error_message = "{version} becomes the Machine's version with its v."
  }
}

run "invalid_captf_contract" {
  command = plan

  variables {
    captf_contract = "v1alpha2"
  }

  expect_failures = [var.captf_contract]
}

run "invalid_bootstrap_format" {
  command = plan

  variables {
    bootstrap_format = "shell"
  }

  expect_failures = [var.bootstrap_format]
}

run "invalid_additional_tags_reserved_key" {
  command = plan

  variables {
    additional_tags = { "captf.io/cluster" = "other" }
  }

  expect_failures = [var.additional_tags]
}

run "invalid_additional_tags_characters" {
  command = plan

  variables {
    additional_tags = { "a<b" = "c" }
  }

  expect_failures = [var.additional_tags]
}

run "invalid_additional_tags_count" {
  command = plan

  variables {
    additional_tags = { for i in range(45) : "tag${i}" => "v" }
  }

  expect_failures = [var.additional_tags]
}

run "invalid_external_cluster_exports" {
  command = plan

  variables {
    external_cluster_exports = { schema = "captf.io/azure-cluster/v0" }
  }

  expect_failures = [var.external_cluster_exports]
}

run "invalid_image_id" {
  command = plan

  variables {
    image_id = null
  }

  expect_failures = [var.image_id]
}

run "invalid_os_disk_size_gib" {
  command = plan

  variables {
    os_disk_size_gib = 10
  }

  expect_failures = [var.os_disk_size_gib]
}

run "invalid_os_disk_storage_account_type" {
  command = plan

  variables {
    os_disk_storage_account_type = "UltraSSD_LRS"
  }

  expect_failures = [var.os_disk_storage_account_type]
}

run "invalid_vm_size" {
  command = plan

  variables {
    vm_size = "D4s_v5"
  }

  expect_failures = [var.vm_size]
}
