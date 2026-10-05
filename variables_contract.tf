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

# Contract inputs of the machine role, v1alpha1, in contract order and with
# the contract's types
# (https://captf.io/docs/module-author/contract/v1alpha1/machine.html#inputs).

# Read only by its own validation.
# tflint-ignore: terraform_unused_declarations
variable "captf_contract" {
  description = "Contract version the controller generated the root module for (common.md \"Inputs\")."
  type        = string

  validation {
    condition     = var.captf_contract == "v1alpha1"
    error_message = "captf_contract must be \"v1alpha1\": this module implements contract v1alpha1 only."
  }
}

# Names come from machine_name and the cluster's exports.
# tflint-ignore: terraform_unused_declarations
variable "captf_cluster" {
  description = "The owning CAPI Cluster: name and namespace (common.md \"Inputs\")."
  type = object({
    name      = string
    namespace = string
  })
}

# The TerraformMachine reaches Azure through captf_tags.
# tflint-ignore: terraform_unused_declarations
variable "captf_object" {
  description = "The TerraformMachine being reconciled (common.md \"Inputs\")."
  type = object({
    kind      = string
    name      = string
    namespace = string
  })
}

variable "captf_cluster_outputs" {
  description = "The cluster role's exports (schema captf.io/azure-cluster/v1), or {} for an externally managed TerraformCluster (common.md \"captf_cluster_outputs\")."
  type        = any

  validation {
    condition     = try(length(keys(var.captf_cluster_outputs)) == 0, false) || try(var.captf_cluster_outputs.schema == "captf.io/azure-cluster/v1", false)
    error_message = "captf_cluster_outputs must be the exports of the CAPTF Azure cluster module (schema captf.io/azure-cluster/v1) or {}: use an azure-cluster image of a compatible version for the TerraformCluster."
  }
}

variable "captf_tags" {
  description = "Tags the controller sets on every object (common.md \"captf_tags\"); applied to every taggable resource through local.tags."
  type        = map(string)
}

variable "machine_name" {
  description = "The owning CAPI Machine's name; the VM and its hostname are named after it (machine.md \"Inputs\")."
  type        = string
}

variable "bootstrap_data" {
  description = "Base64 of the bootstrap Secret's value (machine.md \"bootstrap_data\"). Passed on as custom data, never decoded."
  type        = string
  sensitive   = true
}

variable "bootstrap_format" {
  description = "Format of the bootstrap payload: cloud-config or ignition (machine.md \"bootstrap_format\")."
  type        = string

  validation {
    condition     = contains(["cloud-config", "ignition"], var.bootstrap_format)
    error_message = "bootstrap_format must be cloud-config or ignition."
  }
}

variable "failure_domain" {
  description = "Machine.spec.failureDomain: the availability zone to place the VM in (machine.md \"failure_domain (input)\")."
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "Machine.spec.version, possibly with a +suffix (machine.md \"kubernetes_version (input)\"). Fills {version} and {semver} in image_id."
  type        = string
  default     = null
}

variable "control_plane" {
  description = "True for a control-plane Machine: the VM joins the API load balancer and uses the control-plane subnet, identity and security group (machine.md \"control_plane (input)\")."
  type        = bool
}
