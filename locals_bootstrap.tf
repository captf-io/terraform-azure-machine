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

# Custom data of the VM (DESIGN.md decision 6). Custom data, not user data:
# Azure exposes user data through the instance metadata service to every
# process on the node.
locals {
  # The base64 of a gzip stream starts with H4sI (CONVENTIONS.md section 13).
  bootstrap_gzipped = startswith(var.bootstrap_data, "H4sI")

  # cloud-provider-azure configuration for this node's identity.
  cloud_provider_config = jsonencode(merge(try(local.cluster.cloud_provider_config, {}), { userAssignedIdentityID = local.identity_client_id }))
  apiserver_hairpin     = local.register_backend && try(local.api.hairpin_workaround, false)

  boothook = templatefile("${path.module}/templates/boothook.sh.tftpl", {
    apiserver_hairpin     = local.apiserver_hairpin
    backend_port          = try(local.api.backend_port, 0)
    cloud_provider_config = local.cloud_provider_config
    frontend_ip           = try(local.api.frontend_ip, "")
    frontend_port         = try(local.api.port, 0)
    supervisor_port       = try(coalesce(local.api.supervisor_port, 0), 0)
  })

  # cloud-config payloads are wrapped in a MIME multipart: the boothook,
  # then the payload as an opaque base64 part that is never decoded here.
  # text/plain makes cloud-init detect the payload's type itself, which
  # keeps CABPK's "## template: jinja" header working; application/x-gzip
  # makes it decompress first (cloudinit/user_data.py). Ignition has no
  # such envelope and passes through unchanged.
  user_data_mime = templatefile("${path.module}/templates/user_data.mime.tftpl", {
    boothook             = local.boothook
    boundary             = "==CAPTF-BOUNDARY=="
    payload_base64       = join("\n", regexall(".{1,76}", var.bootstrap_data))
    payload_content_type = local.bootstrap_gzipped ? "application/x-gzip" : "text/plain; charset=\"utf-8\""
  })
  custom_data = var.bootstrap_format == "cloud-config" ? base64encode(local.user_data_mime) : var.bootstrap_data

  # Azure takes at most 65535 bytes of custom data, which is 87380 base64
  # characters (https://learn.microsoft.com/rest/api/compute/virtual-machines/create-or-update#osprofile).
  custom_data_max_length = 87380
}
