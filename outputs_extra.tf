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

# Non-contract outputs, alphabetical. The controller never reads them; they
# help when inspecting a machine's state.

output "network_interface_id" {
  description = "ARM ID of the VM's NIC."
  value       = try(azurerm_network_interface.node_network_interface[0].id, null)
}

output "virtual_machine_id" {
  description = "ARM ID of the VM."
  value       = try(azurerm_linux_virtual_machine.node_virtual_machine[0].id, null)
}
