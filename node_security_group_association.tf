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

# Puts the NIC under its role's network security group from the cluster
# module (DESIGN.md decision 3).
resource "azurerm_network_interface_security_group_association" "node_security_group_association" {
  count = local.exports_available ? 1 : 0

  network_interface_id      = azurerm_network_interface.node_network_interface[0].id
  network_security_group_id = local.security_group_id
}
