# terraform

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.56.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the AKS cluster | `string` | `"aks-poc-cluster"` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | The name of the storage container for the backend | `string` | `"tfstatestore"` | no |
| <a name="input_dns_prefix"></a> [dns\_prefix](#input\_dns\_prefix) | DNS prefix for the AKS cluster | `string` | `"akspoc"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources | `string` | `"westeurope"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Number of nodes in the default node pool | `number` | `1` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription ID | `string` | n/a | yes |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | VM size for the nodes | `string` | `"Standard_D2s_v3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_fqdn"></a> [aks\_fqdn](#output\_aks\_fqdn) | AKS cluster API endpoint (for kubectl management, not web apps) |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the AKS cluster |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | Kubernetes config for kubectl access |
| <a name="output_kube_config_context"></a> [kube\_config\_context](#output\_kube\_config\_context) | Kubernetes context name for kubectl |
| <a name="output_webapp_url"></a> [webapp\_url](#output\_webapp\_url) | Web application URL (nginx with DNS label) |
<!-- END_TF_DOCS -->
