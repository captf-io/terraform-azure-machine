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

# The azurerm provider for the machine role. Credentials come from the
# identity Secret's ARM_* environment variables; the subscription is the
# cluster's, from exports, so a machine always lands next to its cluster.
provider "azurerm" {
  # Registration is a prerequisite (README "Prerequisites").
  resource_provider_registrations = "none"
  # Null (an externally managed cluster without external_cluster_exports)
  # falls back to ARM_SUBSCRIPTION_ID; the precondition on the VM then fails
  # with the actionable message.
  subscription_id = local.subscription_id

  features {
    virtual_machine {
      # The OS disk belongs to the machine: destroy deletes it, and shuts the
      # VM down gracefully first. Both are the provider defaults, set so a
      # reader does not have to know them.
      delete_os_disk_on_deletion     = true
      skip_shutdown_and_force_delete = false
    }
  }
}
