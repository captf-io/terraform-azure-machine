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

# Registers a control-plane NIC in the API load balancer's backend pool, in
# this machine's own state, so destroy deregisters it
# (https://captf.io/docs/module-author/contract/v1alpha1/machine.html#control-plane-machines).
resource "azurerm_network_interface_backend_address_pool_association" "api_backend_pool_association" {
  count = local.register_backend ? 1 : 0

  backend_address_pool_id = try(local.api.backend_pool_id, null)
  ip_configuration_name   = local.ip_configuration_name
  network_interface_id    = azurerm_network_interface.node_network_interface[0].id
}
