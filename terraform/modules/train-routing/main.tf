# -----------------------------------------------------------------------------
# Train Routing Application Module
# Shared Kubernetes resources for both local and Azure deployments
# -----------------------------------------------------------------------------

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "train-routing"
}

variable "environment" {
  description = "Environment: local or azure"
  type        = string
}

variable "backend_image" {
  description = "Backend container image"
  type        = string
  default     = "ghcr.io/esysc/defi-fullstack/backend:latest"
}

variable "frontend_image" {
  description = "Frontend container image"
  type        = string
  default     = "ghcr.io/esysc/defi-fullstack/frontend:latest"
}

variable "backend_replicas" {
  description = "Number of backend replicas"
  type        = number
  default     = 1
}

variable "frontend_replicas" {
  description = "Number of frontend replicas"
  type        = number
  default     = 1
}

variable "postgres_user" {
  description = "PostgreSQL username"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "train_routing"
}

variable "app_secret" {
  description = "Symfony application secret"
  type        = string
  default     = "change-this-to-a-secure-random-string"
  sensitive   = true
}

variable "jwt_passphrase" {
  description = "JWT key passphrase (only used if providing external keys)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "generate_jwt_keys" {
  description = "Auto-generate JWT keys for multi-replica consistency (recommended)"
  type        = bool
  default     = true
}

variable "frontend_dns_label" {
  description = "DNS label for Azure LoadBalancer (azure only)"
  type        = string
  default     = "train-routing-app"
}

variable "location" {
  description = "Azure region (for DNS URL output)"
  type        = string
  default     = "westeurope"
}

# -----------------------------------------------------------------------------
# Local variables
# -----------------------------------------------------------------------------

locals {
  is_local = var.environment == "local"
  is_azure = var.environment == "azure"
}

# -----------------------------------------------------------------------------
# JWT Key Generation
# -----------------------------------------------------------------------------

# Auto-generate RSA keys for JWT signing (stored in Terraform state)
resource "tls_private_key" "jwt" {
  count     = var.generate_jwt_keys ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# -----------------------------------------------------------------------------
# Namespace
# -----------------------------------------------------------------------------

resource "kubernetes_namespace" "train_routing" {
  metadata {
    name = var.namespace
    labels = {
      app     = "train-routing"
      project = "train-routing"
    }
  }
}

# -----------------------------------------------------------------------------
# Secrets
# -----------------------------------------------------------------------------

resource "kubernetes_secret" "train_routing_secrets" {
  metadata {
    name      = "train-routing-secrets"
    namespace = kubernetes_namespace.train_routing.metadata[0].name
  }

  data = {
    POSTGRES_USER     = var.postgres_user
    POSTGRES_PASSWORD = var.postgres_password
    POSTGRES_DB       = var.postgres_db
    DATABASE_URL      = "postgresql://${var.postgres_user}:${var.postgres_password}@postgres:5432/${var.postgres_db}"
    APP_SECRET        = var.app_secret
    JWT_PASSPHRASE    = var.jwt_passphrase
  }
}

# JWT keys secret (auto-generated for multi-replica consistency)
resource "kubernetes_secret" "jwt_keys" {
  count = var.generate_jwt_keys ? 1 : 0

  metadata {
    name      = "jwt-keys"
    namespace = kubernetes_namespace.train_routing.metadata[0].name
  }

  data = {
    # Use PKCS#8 format for private key (required by LexikJWTAuthenticationBundle)
    "private.pem" = tls_private_key.jwt[0].private_key_pem_pkcs8
    "public.pem"  = tls_private_key.jwt[0].public_key_pem
  }
}

# -----------------------------------------------------------------------------
# PostgreSQL
# -----------------------------------------------------------------------------

# PVC only for Azure (local uses emptyDir)
resource "kubernetes_persistent_volume_claim" "postgres" {
  count = local.is_azure ? 1 : 0

  metadata {
    name      = "postgres-pvc"
    namespace = kubernetes_namespace.train_routing.metadata[0].name
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "managed-csi"
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }

  # Don't wait for binding - managed-csi uses WaitForFirstConsumer
  wait_until_bound = false
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.train_routing.metadata[0].name
    labels = {
      app = "postgres"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:16-alpine"

          port {
            container_port = 5432
          }

          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.train_routing_secrets.metadata[0].name
                key  = "POSTGRES_USER"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.train_routing_secrets.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }

          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.train_routing_secrets.metadata[0].name
                key  = "POSTGRES_DB"
              }
            }
          }

          # Use subdirectory to avoid lost+found issue on Azure disks
          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }

          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
          }

          readiness_probe {
            exec {
              command = ["pg_isready", "-U", "postgres"]
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }

        # Use PVC for Azure, emptyDir for local
        dynamic "volume" {
          for_each = local.is_azure ? [1] : []
          content {
            name = "postgres-storage"
            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim.postgres[0].metadata[0].name
            }
          }
        }

        dynamic "volume" {
          for_each = local.is_local ? [1] : []
          content {
            name = "postgres-storage"
            empty_dir {}
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.train_routing.metadata[0].name
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}

# -----------------------------------------------------------------------------
# Backend
# -----------------------------------------------------------------------------

resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.train_routing.metadata[0].name
    labels = {
      app = "backend"
    }
  }

  spec {
    replicas = var.backend_replicas

    selector {
      match_labels = {
        app = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "backend"
        }
      }

      spec {
        init_container {
          name  = "wait-for-postgres"
          image = "busybox:1.36"
          command = [
            "sh", "-c",
            "until nc -z postgres 5432; do echo waiting for postgres; sleep 2; done"
          ]
        }

        container {
          name  = "backend"
          image = var.backend_image

          port {
            container_port = 8000
          }

          env {
            name  = "APP_ENV"
            value = "dev"
          }

          env {
            name  = "APP_DEBUG"
            value = "1"
          }

          env {
            name = "APP_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.train_routing_secrets.metadata[0].name
                key  = "APP_SECRET"
              }
            }
          }

          env {
            name = "DATABASE_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.train_routing_secrets.metadata[0].name
                key  = "DATABASE_URL"
              }
            }
          }

          env {
            name  = "JWT_SECRET_KEY"
            value = var.generate_jwt_keys ? "/etc/jwt/private.pem" : "%kernel.project_dir%/config/jwt/private.pem"
          }

          env {
            name  = "JWT_PUBLIC_KEY"
            value = var.generate_jwt_keys ? "/etc/jwt/public.pem" : "%kernel.project_dir%/config/jwt/public.pem"
          }

          env {
            name = "JWT_PASSPHRASE"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.train_routing_secrets.metadata[0].name
                key  = "JWT_PASSPHRASE"
              }
            }
          }

          env {
            name  = "CORS_ALLOW_ORIGIN"
            value = "^https?://.*$"
          }

          resources {
            requests = {
              memory = "128Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }

          # Mount JWT keys if auto-generated
          dynamic "volume_mount" {
            for_each = var.generate_jwt_keys ? [1] : []
            content {
              name       = "jwt-keys"
              mount_path = "/etc/jwt"
              read_only  = true
            }
          }

          readiness_probe {
            http_get {
              path = "/api/v1/stations"
              port = 8000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }

        # Volume for JWT keys (auto-generated)
        dynamic "volume" {
          for_each = var.generate_jwt_keys ? [1] : []
          content {
            name = "jwt-keys"
            secret {
              secret_name = kubernetes_secret.jwt_keys[0].metadata[0].name
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.postgres]
}

resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.train_routing.metadata[0].name
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "backend"
    }

    port {
      port        = 8000
      target_port = 8000
    }
  }
}

# -----------------------------------------------------------------------------
# Frontend
# -----------------------------------------------------------------------------

resource "kubernetes_config_map" "frontend_nginx" {
  metadata {
    name      = "frontend-nginx-config"
    namespace = kubernetes_namespace.train_routing.metadata[0].name
  }

  data = {
    "default.conf" = <<-EOT
      server {
          listen 3000;
          server_name localhost;
          root /usr/share/nginx/html;
          index index.html;

          location / {
              try_files $uri $uri/ /index.html;
          }

          location /api/ {
              proxy_pass http://backend:8000;
              proxy_http_version 1.1;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
          }
      }
    EOT
  }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.train_routing.metadata[0].name
    labels = {
      app = "frontend"
    }
  }

  spec {
    replicas = var.frontend_replicas

    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }

      spec {
        container {
          name  = "frontend"
          image = var.frontend_image

          port {
            container_port = 3000
          }

          resources {
            requests = {
              memory = "64Mi"
              cpu    = "50m"
            }
            limits = {
              memory = "128Mi"
              cpu    = "200m"
            }
          }

          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx/conf.d/default.conf"
            sub_path   = "default.conf"
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }

        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map.frontend_nginx.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.backend]
}

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.train_routing.metadata[0].name
    labels = {
      app = "frontend"
    }
    annotations = local.is_azure ? {
      "service.beta.kubernetes.io/azure-dns-label-name" = var.frontend_dns_label
    } : {}
  }

  spec {
    type = local.is_azure ? "LoadBalancer" : "NodePort"

    selector = {
      app = "frontend"
    }

    port {
      port        = local.is_azure ? 80 : 3000
      target_port = 3000
      node_port   = local.is_local ? 30000 : null
    }
  }
}

# -----------------------------------------------------------------------------
# Outputs
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
