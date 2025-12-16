# AKS Terraform POC

A minimal, cost-effective proof of concept for deploying Kubernetes on Azure using Terraform and GitHub Actions.

## Overview

This POC demonstrates:

- **Infrastructure as Code**: Terraform-provisioned AKS cluster (1 node, free tier control plane)
- **Local Validation**: Pre-commit hooks for Terraform formatting and validation
- **CI/CD**: GitHub Actions workflow for Terraform planning and Azure authentication
- **Application Deployment**: Nginx running on Kubernetes with LoadBalancer service
- **Zero Cost**: Uses Azure free credits; designed to be destroyed immediately after testing

## Prerequisites

### Azure Account

- Create a free Azure account with 200 USD / 30-day credit
- The AKS control plane is free on the "Free" SKU tier
- Single `Standard_B2s` node ~$0.05/hour; total test cost is minimal if cluster is destroyed after use

### Local Tools (All Free)

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)
- [Terraform](https://www.terraform.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [Helm](https://helm.sh/docs/intro/install/)
- [pre-commit](https://pre-commit.com/) (for local Terraform validation)

```bash
# macOS (brew)
brew install azure-cli terraform kubectl helm pre-commit

# Or download from:
# - Azure CLI: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
# - Terraform: https://www.terraform.io/downloads
# - kubectl: https://kubernetes.io/docs/tasks/tools/
# - Helm: https://helm.sh/docs/intro/install/
# - pre-commit: https://pre-commit.com/#installation
```

### GitHub

- Public repository (GitHub Actions are free for public repos)

### Setup Pre-commit Hooks (Local Development)

After cloning the repository, initialize pre-commit:

```bash
pre-commit install
```

This will automatically run Terraform validation, formatting, and other checks before each commit. To manually run pre-commit:

```bash
pre-commit run --all-files
```

### GitHub Actions Secrets (For CI/CD)

To enable GitHub Actions to authenticate with Azure, add these secrets to your repository:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add the following secrets:
   - `AZURE_CLIENT_ID`: Your Azure app registration client ID
   - `AZURE_TENANT_ID`: Your Azure tenant ID
   - `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID

**To obtain these values:**

```bash
# Create a service principal for GitHub Actions
az ad sp create-for-rbac --name "github-actions" --role Contributor

# This will output: clientId, displayName, password, tenant
# Use clientId as AZURE_CLIENT_ID and tenant as AZURE_TENANT_ID

# Get subscription ID
az account show --query id
```

## Quick Start

### 1. Authenticate with Azure

```bash
az login
az account show  # Verify you're using the correct subscription
```

### 2. Initialize and Deploy Infrastructure

```bash
cd terraform
terraform init
terraform plan     # Review changes
terraform apply    # Type 'yes' to confirm
```

Wait for AKS cluster creation (~5-10 minutes).

### 3. Configure kubectl

```bash
az aks get-credentials \
  --resource-group rg-aks-poc \
  --name aks-poc-cluster \
  --overwrite-existing

kubectl get nodes  # Verify cluster is ready
```

### 4. Deploy Nginx

```bash
kubectl apply -f k8s/nginx-deployment.yaml
kubectl apply -f k8s/nginx-service.yaml

kubectl get svc nginx-service  # Wait for EXTERNAL-IP to appear
```

Once `EXTERNAL-IP` is assigned, open it in your browser to see the Nginx welcome page.

### 5. Clean Up (IMPORTANT)

```bash
cd terraform
terraform destroy  # Type 'yes' to confirm

# Or if terraform destroy fails:
az group delete --name rg-aks-poc --yes --no-wait
```

**Destroy immediately after testing to avoid charges.** The entire test window should cost $0–$5 at most, covered by Azure free credits.

## Project Structure

```shell
.
├── terraform/              # Infrastructure as Code
│   ├── main.tf            # AKS cluster + resource group
│   ├── variables.tf       # Input variables
│   └── outputs.tf         # Cluster connection details
├── k8s/                   # Kubernetes manifests
│   ├── nginx-deployment.yaml
│   └── nginx-service.yaml
├── .github/workflows/     # CI/CD
│   └── ci.yaml           # GitHub Actions: Terraform plan & Azure auth
├── .pre-commit-config.yaml # Local validation hooks
├── .gitignore            # Git ignore rules
└── README.md             # This file
```

## Configuration

All defaults in `terraform/variables.tf` can be overridden:

```bash
terraform apply -var="location=eastus" -var="node_count=2"
```

| Variable | Default | Notes |
|----------|---------|-------|
| `location` | westeurope | Azure region |
| `node_count` | 1 | Number of nodes (keep at 1 for cost) |
| `vm_size` | Standard_B2s | Small, cheap VM for POC |
| `cluster_name` | aks-poc-cluster | AKS cluster name |

## Cost Management

| Component | Cost | Duration |
|-----------|------|----------|
| AKS Control Plane | **Free** (Free tier) | Always |
| 1× Standard_B2s Node | ~$0.05/hour | While running |
| LoadBalancer (public IP) | ~$0.005/hour | While running |
| **Total for 30-minute test** | **~$0.05** | Covered by free credits |

**Key: Destroy the cluster immediately after testing.**

## Troubleshooting

### Unable to authenticate

```bash
az logout
az login
```

### Terraform state issues

```bash
rm -rf terraform/.terraform
rm -f terraform/.terraform.lock.hcl
terraform init
```

### kubectl can't connect

```bash
# Refresh credentials
az aks get-credentials --resource-group rg-aks-poc --name aks-poc-cluster --overwrite-existing

# Check context
kubectl config current-context
```

### Service still pending IP

```bash
# Wait a bit longer, then check again
kubectl get svc nginx-service -w  # Watch for EXTERNAL-IP
```

## Next Steps

From this minimal foundation, you can:

- Add Helm charts for complex deployments
- Implement autoscaling and monitoring
- Set up CI/CD for application deployments
- Add networking policies and ingress controllers
- Configure persistent storage (AzureDisk, AzureFiles)

## License

Open source, MIT. Use freely for learning and demonstrations.
