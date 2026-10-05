# terraform-azure-machine

The CAPTF Azure machine module: the Terraform/OpenTofu root module behind `TerraformMachine`. Images are published from [azure-modules](https://github.com/captf-io/azure-modules).

The `machine` role of the CAPTF Azure modules: one Kubernetes node on one
Azure Linux VM. It implements the
[`v1alpha1` machine role](https://captf.io/docs/module-author/contract/v1alpha1/machine.html)
and ships as `ghcr.io/captf-io/azure-machine`. Control-plane and worker
machines share it; `control_plane` picks the subnet, identity, security
groups and load balancer registration. The reasons behind every choice are
in [DESIGN.md](https://github.com/captf-io/terraform-azure-machine/blob/main/DESIGN.md).

## Usage

CAPTF runs this module from the module image `ghcr.io/captf-io/azure-machine`: set the image on
a `TerraformMachine`'s `spec.source.image` (through a `TerraformMachineTemplate`), and the controller renders every
input. The module is also published to the Terraform Registry as
`captf-io/machine/azure` and can be called directly:

```hcl
module "machine" {
  source  = "captf-io/machine/azure"
  version = "~> 0.1"

  # The contract inputs the controller would render (captf_contract,
  # captf_cluster, captf_object, captf_tags, ...; see Inputs), and any
  # user variables.
}
```

Called directly, the module is a CAPTF root module first:

- it configures its own `provider "azurerm"` block, so the calling
  module cannot use `count`, `for_each` or `depends_on` on it, and the
  provider takes its credentials from the environment (see Identity
  Secret);
- its providers are pinned to exact versions (`versions.tf`), which the
  calling configuration has to accept;
- you set the `captf_*` inputs yourself.

## What it creates

Everything lands in the cluster's resource group, named in the cluster's
`exports`.

| Resource | Count | Purpose |
| --- | --- | --- |
| `azurerm_network_interface.node_network_interface` | 1 | The VM's NIC in the control-plane or worker subnet |
| `azurerm_network_interface_security_group_association.node_security_group_association` | 1 | Puts the NIC under its role's network security group |
| `azurerm_network_interface_application_security_group_association.node_application_security_group_association` | 1 | Makes the NIC a member of its role's application security group |
| `azurerm_network_interface_backend_address_pool_association.api_backend_pool_association` | 0-1 | Registers a control-plane NIC in the API load balancer's backend pool, from this machine's own state |
| `azurerm_linux_virtual_machine.node_virtual_machine` | 1 | The node, booted with the bootstrap data as custom data |

It reads `azurerm_resources` (whether the VM exists, listed
subscription-wide and filtered to the cluster's resource group, so a
deleted group cannot fail a refresh or destroy) and, when it does,
`azurerm_virtual_machine` (its power state) on every refresh. The VM is
created after its NIC associations, so it boots in its security groups
and, on the control plane, behind the load balancer. Without exports (an
externally managed cluster and no `external_cluster_exports`) it creates
nothing and fails a precondition.

## Prerequisites

- A cluster created by the `cluster` role, or `external_cluster_exports`
  for an externally managed one.
- **Image.** A Linux image with kubeadm, the kubelet and a container
  runtime for the Machine's Kubernetes version, cloud-init, `curl`,
  `iptables` and `systemd-run` (the hairpin workaround), such as the
  [image-builder](https://image-builder.sigs.k8s.io/) CAPI images. The CAPZ
  reference images work:
  `/communityGalleries/ClusterAPI-f72ceb4f-5159-4c26-a0fe-2ea738f0d019/images/capi-ubun2-2404/versions/{semver}`.
  `trusted_launch` needs a generation 2 image built for it; the CAPZ
  reference images are not
  ([CAPZ trusted launch](https://capz.sigs.k8s.io/self-managed/trusted-launch-for-vms)).
- **Quotas.** Regional vCPUs of the VM size's family (DSv5 by default),
  and Spot vCPUs with `spot`.
- **Permissions.** Those of the cluster role cover the machine role. An
  identity you brought to the cluster needs Managed Identity Operator for
  the job identity, which attaches it to the VM.
- **cloud-provider-azure** in the workload cluster: it removes the
  `node.cloudprovider.kubernetes.io/uninitialized` taint and sets
  `Node.spec.providerID`, without which no Machine gets its Node.

## Inputs

Contract inputs used: `captf_cluster_outputs` (the cluster's exports),
`captf_tags`, `machine_name`, `bootstrap_data`, `bootstrap_format`,
`failure_domain`, `kubernetes_version` (fills `{version}` and `{semver}` in
`image_id`) and `control_plane`. `captf_contract` is validated;
`captf_cluster` and `captf_object` are declared and not used.

User variables, set through `spec.template.spec.variables` of the
TerraformMachineTemplate:

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `accelerated_networking` | `bool` | `true` | Accelerated networking on the NIC; turn it off for a `vm_size` without it |
| `additional_tags` | `map(string)` | `{}` | Extra Azure tags on the VM and NIC. Keys starting with `captf.io_` or `captf.io/` are rejected; at most 44 |
| `boot_diagnostics` | `bool` | `true` | Serial console log in Azure-managed storage. It shows boot output, which may include kubeadm's join command |
| `encryption_at_host` | `bool` | `false` | Encrypt temporary disks and caches on the host; needs the `EncryptionAtHost` feature on the subscription. Managed disks are encrypted at rest either way |
| `external_cluster_exports` | `any` | `null` | Exports (schema `captf.io/azure-cluster/v1`) for an externally managed TerraformCluster |
| `image_id` | `string` | `null` (required) | Managed image, Compute Gallery image (version), or community or shared gallery image (version) ID. `{version}` and `{semver}` become the Machine's version, `v1.31.4` and `1.31.4`, without any `+suffix` |
| `ip_forwarding` | `bool` | `false` | IP forwarding on the NIC, for CNIs that route pod addresses natively |
| `os_disk_size_gib` | `number` | `128` | OS disk size, 30-4095 GiB |
| `os_disk_storage_account_type` | `string` | `"Premium_LRS"` | `Standard_LRS`, `StandardSSD_LRS`, `StandardSSD_ZRS`, `Premium_LRS` or `Premium_ZRS` |
| `spot` | `bool` | `false` | A Spot VM, deallocated on eviction, at most the on-demand price, reported interruptible. Workers only: a control-plane machine fails a precondition |
| `trusted_launch` | `bool` | `false` | Secure boot and vTPM |
| `vm_size` | `string` | `"Standard_D4s_v5"` | Azure VM size. The image's capacity labels describe the default: 4 CPUs, 16 GiB, amd64 |

Community and shared gallery IDs are case-sensitive in azurerm 5.7.0:
`/communityGalleries/<gallery>/images/<image>/versions/<version>`.

## Outputs

| Name | Value |
| --- | --- |
| `provider_id` | `azure:///subscriptions/<subscription>/resourceGroups/<group, lowercase>/providers/Microsoft.Compute/virtualMachines/<VM name>` |
| `addresses` | `InternalIP` (the NIC's private address) and `Hostname` (the VM name) |
| `failure_domain` | The VM's zone: the requested failure domain, else one picked from `machine_name`; `null` without zones |
| `interruptible` | `true` for a Spot VM |
| `health` | See Health |
| `network_interface_id` | ARM ID of the NIC (not a contract output) |
| `virtual_machine_id` | ARM ID of the VM (not a contract output) |

**provider_id.** cloud-provider-azure writes `azure://` plus the VM's ARM
ID with the resource group lowercased
([`azure_standard.go`](https://github.com/kubernetes-sigs/cloud-provider-azure/blob/release-1.34/pkg/provider/azure_standard.go)
`GetInstanceIDByNodeName`, `ConvertResourceGroupNameToLower` in
[`azure_wrap.go`](https://github.com/kubernetes-sigs/cloud-provider-azure/blob/release-1.34/pkg/provider/azure_wrap.go)).
It finds the VM by the Node's name, so the Node must be named after the VM:
set `nodeRegistration.name: '{{ ds.meta_data["local_hostname"] }}'` in the
KubeadmConfig, as the examples do.

**VM name.** The VM, its hostname and so its Node are named `machine_name`
when Azure accepts it: at most 64 lowercase letters, digits and inner
hyphens. Any other name is made valid (other characters become `-`), cut
to 55 characters and suffixed with `-` and 8 hex characters of its sha256,
so two Machines never share a VM.

**Failure domain.** With no `failure_domain`, the zone is
`sort(zones)[parseint(substr(sha256(machine_name), 0, 8), 16) % length(zones)]`.
In a region without zones, control-plane VMs join the cluster's
availability set.

## Exports

The machine role reads the cluster's exports (schema
`captf.io/azure-cluster/v1`, [terraform-azure-cluster README](https://github.com/captf-io/terraform-azure-cluster/blob/main/README.md#exports))
and exports nothing.

## Identity Secret

The same Secret as the cluster role
([terraform-azure-cluster README](https://github.com/captf-io/terraform-azure-cluster/blob/main/README.md#identity-secret)). The machine
lands in the cluster's subscription from exports, whatever
`ARM_SUBSCRIPTION_ID` says.

## Bootstrap

`bootstrap_data` reaches the VM as custom data, never as user data, which
Azure's instance metadata service shows to every process on the node.

- **cloud-config**: a MIME multipart of a boothook and the bootstrap data,
  which stays base64 and is never decoded by the module: `text/plain`, so
  cloud-init detects its type (and CABPK's `## template: jinja` header)
  itself, or `application/x-gzip` for a gzipped payload. The boothook
  writes `/etc/kubernetes/azure.json` for cloud-provider-azure and the Azure
  Disk CSI driver (managed identity, no secret) when the file is absent, so
  a file your bootstrap data writes wins on every boot; and, on
  control-plane nodes, it starts the API server hairpin workaround
  ([terraform-azure-cluster README](https://github.com/captf-io/terraform-azure-cluster/blob/main/README.md#api-server-hairpin)). With
  RKE2 (`exports.api.supervisor_port` set) the workaround also covers the
  supervisor port and counts an API server that answers 401 or 403 as up,
  since RKE2 may disable anonymous auth. The exports' address and ports
  must be an IPv4 address and port numbers (a precondition), because they
  reach a root shell script.
- **ignition**: passed through unchanged. Write `azure.json` and the
  hairpin workaround through your Ignition configuration. Gzipped Ignition
  fails a precondition (CONVENTIONS.md section 13).

Azure accepts at most 64 KiB of custom data; a precondition stops a larger
payload. Compress it (CAPRKE2 `gzipUserData`) if a control-plane payload
grows too big.

## Tags

The VM and NIC get `local.tags`: `additional_tags`, then the `captf_tags`
with `/` replaced by `_` (`captf.io/cluster` becomes `captf.io_cluster`).
The captf tags win. Not taggable from this module: the OS disk Azure
creates with the VM, and the NIC associations. They live in the
cluster's resource group, which is tagged.

## Health

`data.azurerm_virtual_machine` fails on a missing VM, which would fail every
refresh and destroy, so the module first lists the VM with
`data.azurerm_resources` and reads the power state only when the listing
finds it.

| Reading | `state` | `healthy` | `reasons` |
| --- | --- | --- | --- |
| Power state `running` | `running` | `true` | `[]` |
| `starting`, or no power state yet | `pending` | `false` | `PowerState/<state>` (`PowerState/unknown` without one) |
| `stopping`, `stopped`, `deallocating`, `deallocated` | `stopped` | `false` | `PowerState/<state>` |
| Any other power state | `unknown` | `false` | `UnknownState` |
| VM in the state but not listed yet (the first apply; ARM's listing lags) | `pending` | `false` | `VirtualMachineNotListed` |
| VM gone (the refresh dropped it) | `terminated` | `false` | `VirtualMachineNotFound` |

The first apply therefore reports `pending`; the controller's next refresh,
30 seconds later, reads the power state.

## Limitations

- One NIC, one OS disk, no data disks: etcd shares the OS disk.
- No public IP; nodes reach the internet through the subnet's egress.
- A Spot VM is deallocated, not deleted, on eviction: it reports `stopped`
  and a MachineHealthCheck replaces it.
- Azure public cloud only.
- Kubernetes images for `{semver}` must exist in the gallery for every
  version you roll to.

## Exceptions

`tfcapi-lint module --strict` passes without allowed warnings.
`hack/check-tags.sh` exempts nothing. One trivy finding is ignored with its
reason in [`.trivyignore.yaml`](https://github.com/captf-io/terraform-azure-machine/blob/main/.trivyignore.yaml): AZU-0068 on the NIC,
whose security group is attached by
`node_security_group_association.tf`. The tests cannot cover the
`terminated` reading (`VirtualMachineNotFound`): a mock provider never drops
a resource on refresh.

## Examples

[`examples/cluster-kubeadm.yaml`](https://github.com/captf-io/terraform-azure-machine/blob/main/examples/cluster-kubeadm.yaml) uses this
role for the control plane and a MachineDeployment. A worker template:

```yaml
apiVersion: infrastructure.cluster.x-k8s.io/v1alpha1
kind: TerraformMachineTemplate
metadata:
  name: demo-md-0
spec:
  template:
    spec:
      source:
        image: ghcr.io/captf-io/azure-machine:v0.1.0-opentofu
      variables:
        image_id: /communityGalleries/ClusterAPI-f72ceb4f-5159-4c26-a0fe-2ea738f0d019/images/capi-ubun2-2404/versions/{semver}
        vm_size: Standard_D8s_v5
        spot: true
```

## Development

The host needs make, podman (or docker with `ENGINE=docker`), jq and Go;
every other tool runs in a digest-pinned container. `make verify` is the
gate. Targets (`make help` lists them):

- `fmt`: format the module with terraform fmt and tofu fmt, in place.
- `fmt-check`: fail on any file terraform fmt or tofu fmt would change.
- `validate`: init and validate on both runtimes and on their floors
  (Terraform 1.5.7, OpenTofu 1.6.3).
- `unit-test`: terraform test and tofu test with mocked providers.
- `tflint`: tflint with the terraform ruleset and the cloud ruleset, per
  `.tflint.hcl`.
- `tfcapi-lint`: `tfcapi-lint module --strict`, built from `PROVIDER_DIR`
  (the cluster-api-provider-terraform checkout; defaults to
  `../cluster-api-provider-terraform`, a sibling clone; the check is skipped
  when it is absent).
- `scan`: trivy config over the repository; ignores live in
  `.trivyignore.yaml`.
- `check-conventions`: `hack/check-layout.sh` and `hack/check-tags.sh`.
- `shellcheck`: shellcheck over `hack/` and every shell template, rendered
  with placeholders.
- `check-headers` / `fix-headers`: fail on, or add, a missing Apache-2.0
  license header.
- `verify`: everything above, in parallel groups.
- `clean`: remove `build/`.

This repository holds the code only; it builds no images. The module images
are built from it by [azure-modules](https://github.com/captf-io/azure-modules).
