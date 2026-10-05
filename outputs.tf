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

# Contract outputs of the machine role, v1alpha1, in contract order
# (https://captf.io/docs/module-author/contract/v1alpha1/machine.html#outputs
# and common.html#outputs). try(): a VM deleted out of band leaves the
# state on refresh, and the refresh must not fail on it.

output "provider_id" {
  description = "azure:///subscriptions/<sub>/resourceGroups/<lowercase group>/providers/Microsoft.Compute/virtualMachines/<name>, as cloud-provider-azure writes Node.spec.providerID (machine.md \"provider_id (output)\"; README \"provider_id\")."
  value       = try("azure:///subscriptions/${lower(local.subscription_id)}/resourceGroups/${lower(local.resource_group_name)}/providers/Microsoft.Compute/virtualMachines/${azurerm_linux_virtual_machine.node_virtual_machine[0].name}", null)
}

output "addresses" {
  description = "The NIC's private address and the hostname, as cloud-provider-azure reports them for the Node (machine.md \"addresses (output)\")."
  value = [
    for a in [
      { type = "InternalIP", address = try(azurerm_network_interface.node_network_interface[0].private_ip_address, null) },
      { type = "Hostname", address = try(azurerm_linux_virtual_machine.node_virtual_machine[0].computer_name, null) },
    ] : a if a.address != null && a.address != ""
  ]
}

output "failure_domain" {
  description = "The VM's availability zone: the requested failure domain, else one picked from machine_name; null in a region without zones (machine.md \"failure_domain (output)\")."
  value       = local.failure_domain
}

output "interruptible" {
  description = "True for a Spot VM (machine.md \"interruptible (output)\")."
  value       = try(azurerm_linux_virtual_machine.node_virtual_machine[0].priority == "Spot", null)
}

output "health" {
  description = "Health from the VM's power state (common.md \"Outputs\"; README \"Health\")."
  value       = local.health_reading
}
