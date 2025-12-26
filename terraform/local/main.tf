# -----------------------------------------------------------------------------
# Local Deployment Configuration (Kind)
# -----------------------------------------------------------------------------

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

  # Auto-generate JWT keys (optional for single replica, but good for consistency)
  generate_jwt_keys = true
}
