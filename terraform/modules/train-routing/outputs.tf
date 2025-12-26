# -----------------------------------------------------------------------------
# Train Routing Application Module - Outputs
# -----------------------------------------------------------------------------

output "namespace" {
  value = kubernetes_namespace.train_routing.metadata[0].name
}

output "frontend_url" {
  value = local.is_azure ? (
    "http://${var.frontend_dns_label}.${var.location}.cloudapp.azure.com"
  ) : "http://localhost:30000"
}

output "api_docs_url" {
  value = local.is_azure ? (
    "http://${var.frontend_dns_label}.${var.location}.cloudapp.azure.com/docs"
  ) : "http://localhost:30000/docs"
}
