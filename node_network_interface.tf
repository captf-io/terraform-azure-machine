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

# The VM's NIC in the role's brought subnet. The security group and
# application security group are attached by association resources, so
# they are in place before the VM boots.
resource "azurerm_network_interface" "node_network_interface" {
  count = local.exports_available ? 1 : 0

  accelerated_networking_enabled = var.accelerated_networking
  ip_forwarding_enabled          = var.ip_forwarding
  location                       = local.location
  name                           = local.network_interface_name
  resource_group_name            = local.resource_group_name
  tags                           = local.tags

  ip_configuration {
    name                          = local.ip_configuration_name
    primary                       = true
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    subnet_id                     = local.subnet_id
  }
}
