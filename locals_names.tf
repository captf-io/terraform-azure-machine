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

# Names of the machine's Azure resources (CONVENTIONS.md section 6). The VM
# name is the hostname and the Node name, and cloud-provider-azure finds the
# VM by Node name, so it is machine_name itself whenever Azure accepts it
# (https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute).
locals {
  # A Linux VM name and hostname: at most 64 characters; this module also
  # keeps them to lowercase letters, digits and inner hyphens.
  machine_name_valid = can(regex("^[a-z0-9]([-a-z0-9]{0,62}[a-z0-9])?$", var.machine_name))
  # Otherwise (dots, more than 64 characters): the name made valid, cut to
  # 55 characters, then "-" and 8 hex characters of its sha256, so two
  # Machines never share a VM.
  vm_name = local.machine_name_valid ? var.machine_name : "${trimsuffix(substr(replace(lower(var.machine_name), "/[^a-z0-9-]/", "-"), 0, 55), "-")}-${substr(sha256(var.machine_name), 0, 8)}"

  network_interface_name = "${local.vm_name}-nic"
  os_disk_name           = "${local.vm_name}-os"
  ip_configuration_name  = "primary"
}
