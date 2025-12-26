# -----------------------------------------------------------------------------
# Terraform and Provider Version Requirements
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
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Remote state in Azure Storage
  # Run ./init-remote-backend.sh first to create the storage account
  backend "azurerm" {
    resource_group_name  = "rg-aks-tfstate"
    storage_account_name = "tfstatea95d9530" # tfstate + first 8 chars of subscription ID
    container_name       = "tfstatestore"
    key                  = "azure.terraform.tfstate"
  }
}
