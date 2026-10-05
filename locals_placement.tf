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

# Placement: failure domains are availability zones (README "Exports").
# With no failure domain requested, the zone is picked deterministically
# from machine_name (CONVENTIONS.md section 11).
locals {
  failure_domain_names = sort(keys(try(local.cluster.failure_domains, {})))
  # try(): the index divides by the number of zones, zero without zones.
  failure_domain = var.failure_domain != null ? var.failure_domain : try(
    local.failure_domain_names[parseint(substr(sha256(var.machine_name), 0, 8), 16) % length(local.failure_domain_names)],
    null,
  )
  zone = local.failure_domain

  # Without zones, control-plane VMs share the cluster's availability set.
  availability_set_id = var.control_plane && local.zone == null ? try(local.role_exports.availability_set_id, null) : null
}
