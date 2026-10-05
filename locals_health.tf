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

# Machine health from the VM's power state (CONVENTIONS.md section 10;
# DESIGN.md decision 8). The state comes from data.azurerm_virtual_machine,
# read only when the resource listing finds the VM, because that data source
# fails on a missing VM and would fail every refresh and destroy.
locals {
  listed_virtual_machines = [
    for r in data.azurerm_resources.node_virtual_machine_listing.resources : r
    if lower(r.resource_group_name) == lower(coalesce(local.resource_group_name, "-"))
  ]
  vm_exists = one(azurerm_linux_virtual_machine.node_virtual_machine[*].id) != null
  vm_listed = length(local.listed_virtual_machines) > 0
  # The provider strips the "PowerState/" prefix.
  power_state = try(lower(data.azurerm_virtual_machine.node_virtual_machine_status[0].power_state), null)

  # Azure VM power state -> contract health ("health" in common.md;
  # https://learn.microsoft.com/azure/virtual-machines/states-billing).
  health_by_state = {
    running      = { state = "running", healthy = true, reason = null }
    starting     = { state = "pending", healthy = false, reason = "PowerState/starting" }
    ""           = { state = "pending", healthy = false, reason = "PowerState/unknown" } # no power state yet: still creating
    stopping     = { state = "stopped", healthy = false, reason = "PowerState/stopping" }
    stopped      = { state = "stopped", healthy = false, reason = "PowerState/stopped" }
    deallocating = { state = "stopped", healthy = false, reason = "PowerState/deallocating" }
    deallocated  = { state = "stopped", healthy = false, reason = "PowerState/deallocated" }
  }
  health_mapped = lookup(local.health_by_state, local.power_state == null ? "-" : local.power_state, { state = "unknown", healthy = false, reason = "UnknownState" })

  health_reading = (
    # Deleted out of band: the refresh dropped the VM from the state.
    !local.vm_exists ? { state = "terminated", healthy = false, message = "Azure VM ${local.vm_name} not found", reasons = ["VirtualMachineNotFound"] } :
    # Created by this apply, or ARM's listing has not caught up: the next
    # refresh reads the power state.
    !local.vm_listed || local.power_state == null ? { state = "pending", healthy = false, message = "Azure VM ${local.vm_name} not listed yet", reasons = ["VirtualMachineNotListed"] } :
    {
      state   = local.health_mapped.state
      healthy = local.health_mapped.healthy
      message = "Azure VM power state ${local.power_state == "" ? "unknown" : local.power_state}"
      reasons = local.health_mapped.reason == null ? [] : [local.health_mapped.reason]
    }
  )
}
