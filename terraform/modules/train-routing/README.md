# train-routing

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_config_map_v1.frontend_nginx](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_deployment_v1.backend](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_deployment_v1.frontend](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_deployment_v1.postgres](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_namespace_v1.train_routing](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_persistent_volume_claim_v1.postgres](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim_v1) | resource |
| [kubernetes_secret_v1.jwt_keys](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.train_routing_secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_service_v1.backend](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |
| [kubernetes_service_v1.frontend](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |
| [kubernetes_service_v1.postgres](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |
| [tls_private_key.jwt](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

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
| <a name="input_generate_jwt_keys"></a> [generate\_jwt\_keys](#input\_generate\_jwt\_keys) | Auto-generate JWT keys for multi-replica consistency (recommended) | `bool` | `true` | no |
| <a name="input_jwt_passphrase"></a> [jwt\_passphrase](#input\_jwt\_passphrase) | JWT key passphrase (only used if providing external keys) | `string` | `""` | no |
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
