# -----------------------------------------------------------------------------
# Azure AKS Deployment - Variables
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
  default     = "Standard_D2s_v3"
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
