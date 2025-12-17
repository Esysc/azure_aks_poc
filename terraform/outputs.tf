output "aks_fqdn" {
  description = "AKS cluster API endpoint (for kubectl management, not web apps)"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}
output "kube_config" {
  description = "Kubernetes config for kubectl access"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "kube_config_context" {
  description = "Kubernetes context name for kubectl"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "webapp_url" {
  description = "Web application URL (nginx with DNS label)"
  value       = "http://akspoc-nginx.westeurope.cloudapp.azure.com"
}
