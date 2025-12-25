# train-routing

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_config_map.frontend_nginx](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_deployment.backend](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_deployment.frontend](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_deployment.postgres](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_namespace.train_routing](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_persistent_volume_claim.postgres](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim) | resource |
| [kubernetes_secret.train_routing_secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.backend](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.frontend](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.postgres](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_secret"></a> [app\_secret](#input\_app\_secret) | Symfony application secret | `string` | `"change-this-to-a-secure-random-string"` | no |
| <a name="input_backend_image"></a> [backend\_image](#input\_backend\_image) | Backend container image | `string` | `"ghcr.io/esysc/defi-fullstack/backend:latest"` | no |
| <a name="input_backend_replicas"></a> [backend\_replicas](#input\_backend\_replicas) | Number of backend replicas | `number` | `1` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment: local or azure | `string` | n/a | yes |
| <a name="input_frontend_dns_label"></a> [frontend\_dns\_label](#input\_frontend\_dns\_label) | DNS label for Azure LoadBalancer (azure only) | `string` | `"train-routing-app"` | no |
| <a name="input_frontend_image"></a> [frontend\_image](#input\_frontend\_image) | Frontend container image | `string` | `"ghcr.io/esysc/defi-fullstack/frontend:latest"` | no |
| <a name="input_frontend_replicas"></a> [frontend\_replicas](#input\_frontend\_replicas) | Number of frontend replicas | `number` | `1` | no |
| <a name="input_jwt_passphrase"></a> [jwt\_passphrase](#input\_jwt\_passphrase) | JWT key passphrase | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region (for DNS URL output) | `string` | `"westeurope"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace | `string` | `"train-routing"` | no |
| <a name="input_postgres_db"></a> [postgres\_db](#input\_postgres\_db) | PostgreSQL database name | `string` | `"train_routing"` | no |
| <a name="input_postgres_password"></a> [postgres\_password](#input\_postgres\_password) | PostgreSQL password | `string` | `"postgres"` | no |
| <a name="input_postgres_user"></a> [postgres\_user](#input\_postgres\_user) | PostgreSQL username | `string` | `"postgres"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_docs_url"></a> [api\_docs\_url](#output\_api\_docs\_url) | n/a |
| <a name="output_frontend_url"></a> [frontend\_url](#output\_frontend\_url) | n/a |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | n/a |
<!-- END_TF_DOCS -->
