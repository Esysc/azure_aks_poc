# -----------------------------------------------------------------------------
# Azure AKS Deployment Configuration
# -----------------------------------------------------------------------------

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

  # Auto-generate JWT keys for multi-replica auth consistency
  generate_jwt_keys = true

  depends_on = [azurerm_kubernetes_cluster.aks]
}
