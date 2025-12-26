# AKS Terraform POC

A minimal, cost-effective proof of concept for deploying Kubernetes on Azure using Terraform and GitHub Actions.

## Overview

This POC demonstrates:

- **Infrastructure as Code**: Terraform-provisioned AKS cluster (1 node, free tier control plane)
- **Remote State**: Azure Storage backend for Terraform state management
- **Local Validation**: Pre-commit hooks for Terraform formatting and validation
- **CI/CD**: GitHub Actions workflow for Terraform planning and Azure authentication
- **Application Deployment**: Train Routing & Analytics full-stack app (Vue.js + PHP/Symfony + PostgreSQL)
- **Zero Cost**: Uses Azure free credits; designed to be destroyed immediately after testing

## Prerequisites

### Azure Account

- Create a free Azure account with 200 USD / 30-day credit
- The AKS control plane is free on the "Free" SKU tier
- Single `Standard_B2s` node ~$0.02/hour; total test cost is minimal if cluster is destroyed after use
- **Note**: Register the `Microsoft.Storage` provider before running: `az provider register --namespace Microsoft.Storage`

### Local Tools (All Free)

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)
- [Terraform](https://www.terraform.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [Task](https://taskfile.dev/) (optional - for automated workflows)
- [pre-commit](https://pre-commit.com/) (for local Terraform validation)

```bash
# macOS (brew)
brew install azure-cli terraform kubectl task pre-commit

# Or download from:
# - Azure CLI: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
# - Terraform: https://www.terraform.io/downloads
# - kubectl: https://kubernetes.io/docs/tasks/tools/
# - Task: https://taskfile.dev/installation/
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

### Option A: Local Testing with Kind (No Azure Required)

Test the application locally using Kind (Kubernetes in Docker) without any Azure costs.

#### Prerequisites for Mac Users (Apple Silicon)

If you're on an Apple Silicon Mac (M1/M2/M3), you need to run Colima with x86_64 emulation since the container images are amd64-only:

```bash
# Install Colima and Kind
brew install colima kind lima-additional-guestagents

# Delete existing Colima instance (if any)
colima stop && colima delete

# Start Colima with x86_64 emulation
colima start --arch x86_64 --cpu 4 --memory 6 --vm-type qemu

# Verify architecture
colima status  # Should show arch: x86_64
```

#### Deploy to Kind

```bash
# Create cluster and deploy app
task kind-up

# Check status
task kind-status

# View logs
task kind-logs

# Destroy cluster
task kind-down
```

Access the app at:
- **Frontend**: http://localhost:30000
- **API (via nginx proxy)**: http://localhost:30000/api/v1

#### Validate Terraform (syntax only)

```bash
task validate-local   # Validate local config
task validate-azure   # Validate Azure config
```

### Option B: Azure Deployment

```bash
# 1. Authenticate with Azure
task login

# 2. Deploy to Azure AKS (interactive)
task azure-up

# 3. Check status
task azure-status

# 4. Clean up
task azure-down
```

### Option C: Manual Step-by-Step (Azure)

```bash
# 1. Authenticate with Azure
az login
az account show  # Verify subscription

# 2. Deploy to Azure AKS
cd terraform/azure
terraform init
export TF_VAR_subscription_id=$(az account show --query id -o tsv)
terraform plan     # Review changes
terraform apply    # Type 'yes' to confirm

# Wait ~10 minutes for AKS cluster creation

# 3. Configure kubectl
az aks get-credentials --resource-group aks-poc-rg --name aks-poc-cluster --overwrite-existing
kubectl get nodes  # Verify cluster is ready

# 4. Check application
kubectl get all -n train-routing
kubectl get svc frontend -n train-routing  # Get EXTERNAL-IP

# 5. Clean up (IMPORTANT - avoid charges!)
terraform destroy
```

**Application Features:**
- Train route calculation using Dijkstra's algorithm
- Analytics dashboard for route statistics
- JWT-based authentication (register/login)
- API documentation at `/api/docs`

**Destroy immediately after testing.** Total cost: $0–$5, covered by Azure free credits.

## Project Structure

```shell
.
├── terraform/
│   ├── modules/
│   │   └── train-routing/     # Shared K8s app resources (used by both local & azure)
│   │       ├── main.tf        # Namespace, secrets, deployments, services
│   │       ├── variables.tf   # Input variable definitions
│   │       └── outputs.tf     # Output value definitions
│   ├── local/                 # Local Kind deployment config
│   │   ├── main.tf            # Kubernetes provider + module call
│   │   ├── versions.tf        # Terraform and provider requirements
│   │   └── outputs.tf         # Output value definitions
│   └── azure/                 # Azure AKS deployment config
│       ├── main.tf            # AKS cluster + Kubernetes provider + module call
│       ├── versions.tf        # Terraform, providers, and backend config
│       ├── variables.tf       # Input variable definitions
│       ├── outputs.tf         # Output value definitions
│       └── terraform.tfvars.example
├── kind-config.yaml          # Kind cluster configuration
├── .github/workflows/        # CI/CD
│   └── ci.yaml              # GitHub Actions: Terraform plan
├── Taskfile.yml             # Task automation definitions
├── init-remote-backend.sh   # Initialize Azure storage for Terraform state
├── cleanup.sh               # Complete cleanup script
├── .pre-commit-config.yaml  # Local validation hooks
└── README.md                # This file
```

## Task Commands

Available automated workflows:

```bash
# Local Testing with Kind (no Azure needed)
task kind-up               # Create Kind cluster + deploy app
task kind-down             # Delete Kind cluster + cleanup
task kind-status           # Check Kind pods
task kind-logs             # View pod logs

# Azure Deployment
task login                 # Login to Azure
task azure-up              # Deploy to Azure AKS
task azure-down            # Destroy Azure resources
task azure-status          # Check deployment status
task azure-plan            # Terraform plan for Azure

# Validation
task validate-local        # Validate local Terraform config
task validate-azure        # Validate Azure Terraform config
task clean                 # Remove all Terraform state files
```

## Configuration

### Local (Kind)

No configuration needed - just run `task kind-up`.

### Azure

Copy the example file and fill in your subscription ID:

```bash
cd terraform/azure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

Or pass variables on the command line (subscription ID is auto-detected from `az account`):

```bash
cd terraform/azure
terraform apply -var="location=eastus" -var="node_count=2"
```

| Variable | Default | Notes |
|----------|---------|-------|
| `location` | westeurope | Azure region |
| `node_count` | 2 | Number of nodes |
| `vm_size` | Standard_B2s | VM size for nodes |
| `cluster_name` | aks-poc-cluster | AKS cluster name |
| `backend_replicas` | 2 | Backend pod replicas |
| `frontend_replicas` | 2 | Frontend pod replicas |

## Cost Management

| Component | Cost | Duration |
|-----------|------|----------|
| AKS Control Plane | **Free** (Free tier) | Always |
| 2× Standard_B2s Nodes | ~$0.04/hour | While running |
| LoadBalancer (public IP) | ~$0.005/hour | While running |
| Storage Account (state) | ~$0.02/month | Persistent |
| **Total for 30-minute test** | **~$0.06** | Covered by free credits |

**Key: Destroy the cluster immediately after testing.**

## Troubleshooting

### Unable to authenticate

```bash
az logout
az login
```

### Terraform state issues

```bash
# For local
rm -rf terraform/local/.terraform terraform/local/.terraform.lock.hcl
cd terraform/local && terraform init

# For Azure
rm -rf terraform/azure/.terraform terraform/azure/.terraform.lock.hcl
cd terraform/azure && terraform init
```

### kubectl can't connect

```bash
# For Azure - refresh credentials
az aks get-credentials --resource-group aks-poc-rg --name aks-poc-cluster --overwrite-existing

# For Kind - switch context
kubectl config use-context kind-aks-local

# Check context
kubectl config current-context
```

### Service still pending IP

```bash
# Wait a bit longer, then check again
kubectl get svc frontend -n train-routing -w  # Watch for EXTERNAL-IP
```

### Backend pods not starting

```bash
# Check if PostgreSQL is ready first
kubectl logs -n train-routing deployment/postgres
kubectl get pods -n train-routing

# Check backend logs
kubectl logs -n train-routing deployment/backend
```

### Database connection issues

```bash
# Verify secrets are properly configured
kubectl get secrets -n train-routing
kubectl describe secret train-routing-secrets -n train-routing
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
