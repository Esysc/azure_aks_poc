# -----------------------------------------------------------------------------
# Local Deployment Configuration (Kind)
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

# -----------------------------------------------------------------------------
# Kubernetes Provider - Local Kind Cluster
# -----------------------------------------------------------------------------

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-aks-local"
}

# -----------------------------------------------------------------------------
# Train Routing Application
# -----------------------------------------------------------------------------

module "train_routing" {
  source = "../modules/train-routing"

  environment = "local"
  namespace   = "train-routing"

  # Lower resource usage for local dev
  backend_replicas  = 1
  frontend_replicas = 1
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

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

output "helpful_commands" {
  description = "Useful kubectl commands"
  value = {
    watch_pods     = "kubectl get pods -n train-routing -w"
    backend_logs   = "kubectl logs -n train-routing -l app=backend -f"
    frontend_logs  = "kubectl logs -n train-routing -l app=frontend -f"
    postgres_shell = "kubectl exec -n train-routing -it $(kubectl get pod -n train-routing -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- psql -U postgres -d train_routing"
    run_migrations = "kubectl exec -n train-routing -it $(kubectl get pod -n train-routing -l app=backend -o jsonpath='{.items[0].metadata.name}') -- php bin/console doctrine:migrations:migrate --no-interaction"
    load_fixtures  = "kubectl exec -n train-routing -it $(kubectl get pod -n train-routing -l app=backend -o jsonpath='{.items[0].metadata.name}') -- php bin/console doctrine:fixtures:load --no-interaction"
  }
}
