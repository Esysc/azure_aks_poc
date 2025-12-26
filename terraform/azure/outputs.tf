# -----------------------------------------------------------------------------
# Azure AKS Deployment - Outputs
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
