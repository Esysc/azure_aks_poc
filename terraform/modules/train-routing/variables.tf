# -----------------------------------------------------------------------------
# Train Routing Application Module - Variables
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
