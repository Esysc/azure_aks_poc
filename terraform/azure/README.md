# azure

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.35 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_train_routing"></a> [train\_routing](#module\_train\_routing) | ../modules/train-routing | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_resource_group.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_replicas"></a> [backend\_replicas](#input\_backend\_replicas) | Number of backend replicas | `number` | `2` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | AKS cluster name | `string` | `"aks-poc-cluster"` | no |
| <a name="input_frontend_dns_label"></a> [frontend\_dns\_label](#input\_frontend\_dns\_label) | DNS label for the frontend LoadBalancer | `string` | `"train-routing-app"` | no |
| <a name="input_frontend_replicas"></a> [frontend\_replicas](#input\_frontend\_replicas) | Number of frontend replicas | `number` | `2` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version | `string` | `"1.30"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | `"westeurope"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Number of nodes in the default node pool | `number` | `2` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | `"aks-poc-rg"` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription ID | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | <pre>{<br/>  "Environment": "Production",<br/>  "ManagedBy": "Terraform",<br/>  "Project": "AKS-POC"<br/>}</pre> | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | VM size for the default node pool | `string` | `"Standard_B2s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_docs_url"></a> [api\_docs\_url](#output\_api\_docs\_url) | API documentation URL |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | AKS cluster name |
| <a name="output_frontend_url"></a> [frontend\_url](#output\_frontend\_url) | Frontend application URL |
| <a name="output_kube_config_command"></a> [kube\_config\_command](#output\_kube\_config\_command) | Command to configure kubectl |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Kubernetes namespace |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name |
<!-- END_TF_DOCS -->
