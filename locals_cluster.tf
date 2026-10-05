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

# The cluster's exports: captf_cluster_outputs, or external_cluster_exports
# when the TerraformCluster is externally managed and the controller passes
# {} (CONVENTIONS.md section 12; README "Exports").
locals {
  externally_managed = try(length(keys(var.captf_cluster_outputs)) == 0, false)
  # Both sides are `any` and may be objects of different shapes, which a
  # conditional cannot unify; their JSON strings can.
  cluster = jsondecode(local.externally_managed ? jsonencode(var.external_cluster_exports) : jsonencode(var.captf_cluster_outputs))
  # Without exports nothing can be placed: every resource has count 0 and
  # the precondition on the VM listing explains what to set.
  exports_available = local.cluster != null

  # try(): with no exports every value is null.
  role_key                      = var.control_plane ? "control_plane" : "worker"
  role_exports                  = try(local.cluster[local.role_key], null)
  subscription_id               = try(local.cluster.subscription_id, null)
  location                      = try(local.cluster.region, null)
  resource_group_name           = try(local.cluster.resource_group_name, null)
  subnet_id                     = try(var.control_plane ? local.cluster.subnet_id : local.cluster.worker_subnet_id, null)
  admin_username                = try(local.cluster.admin_username, null)
  admin_ssh_public_key          = try(local.cluster.admin_ssh_public_key, null)
  identity_id                   = try(local.role_exports.identity_id, null)
  identity_client_id            = try(local.role_exports.identity_client_id, null)
  security_group_id             = try(local.role_exports.network_security_group_id, null)
  application_security_group_id = try(local.role_exports.application_security_group_id, null)

  # Control-plane machines join the API load balancer the cluster module
  # created; none exists when the endpoint is the user's (api = null).
  api              = try(local.cluster.api, null)
  register_backend = var.control_plane && local.api != null
}
