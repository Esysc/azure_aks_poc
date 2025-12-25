# -----------------------------------------------------------------------------
# Azure AKS Deployment Configuration
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }

  # Uncomment to use remote state in Azure Storage
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "tfstateakspocstorage"
  #   container_name       = "tfstate"
  #   key                  = "azure.terraform.tfstate"
  # }
}

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "aks-poc-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "aks-poc-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.32"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_B2s"
}

variable "backend_replicas" {
  description = "Number of backend replicas"
  type        = number
  default     = 2
}

variable "frontend_replicas" {
  description = "Number of frontend replicas"
  type        = number
  default     = 2
}

variable "frontend_dns_label" {
  description = "DNS label for the frontend LoadBalancer"
  type        = string
  default     = "train-routing-app"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "AKS-POC"
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# Azure Provider
# -----------------------------------------------------------------------------

provider "azurerm" {
  subscription_id = var.subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# -----------------------------------------------------------------------------
# AKS Cluster
# -----------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  tags                = var.tags

  default_node_pool {
    name                 = "default"
    node_count           = var.node_count
    vm_size              = var.vm_size
    auto_scaling_enabled = false
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.0.0.10"
    service_cidr   = "10.0.0.0/16"
  }
}

# -----------------------------------------------------------------------------
# Kubernetes Provider - Azure AKS
# -----------------------------------------------------------------------------

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

# -----------------------------------------------------------------------------
# Train Routing Application
# -----------------------------------------------------------------------------

module "train_routing" {
  source = "../modules/train-routing"

  environment = "azure"
  namespace   = "train-routing"
  location    = var.location

  backend_replicas   = var.backend_replicas
  frontend_replicas  = var.frontend_replicas
  frontend_dns_label = var.frontend_dns_label

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.aks.name
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "kube_config_command" {
  description = "Command to configure kubectl"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.aks.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}

output "namespace" {
  description = "Kubernetes namespace"
  value       = module.train_routing.namespace
}

output "frontend_url" {
  description = "Frontend application URL"
  value       = module.train_routing.frontend_url
}

output "api_docs_url" {
  description = "API documentation URL"
  value       = module.train_routing.api_docs_url
}
