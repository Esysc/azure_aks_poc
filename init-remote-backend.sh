#!/bin/bash
# init-remote-backend.sh
# Creates Azure storage account and container for Terraform remote state if they do not exist.

set -e

# Get current subscription and set it explicitly (fixes Azure CLI context issues)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az account set --subscription "$SUBSCRIPTION_ID"

# Hardcoded backend values (keep in sync with main.tf backend block)
RESOURCE_GROUP="rg-aks-tfstate"  # Separate RG for state storage
LOCATION="westeurope"
STORAGE_ACCOUNT="tfstate${SUBSCRIPTION_ID:0:8}"  # Unique based on subscription
CONTAINER_NAME="tfstatestore"

# Print parsed variables and exit for testing
echo "Backend values used for remote state:"
echo "SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo "RESOURCE_GROUP: $RESOURCE_GROUP"
echo "LOCATION: $LOCATION"
echo "STORAGE_ACCOUNT: $STORAGE_ACCOUNT"
echo "CONTAINER_NAME: $CONTAINER_NAME"

# Create resource group if it doesn't exist
echo "Checking resource group..."
az group show --name "$RESOURCE_GROUP" 2>/dev/null || \
  az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# Create storage account if it doesn't exist
echo "Checking storage account..."
if ! az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --subscription "$SUBSCRIPTION_ID" 2>/dev/null; then
  echo "Creating storage account..."
  az storage account create --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --location "$LOCATION" --sku Standard_LRS --subscription "$SUBSCRIPTION_ID" 2>/dev/null || echo "Storage account already exists, using it..."
fi

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group "$RESOURCE_GROUP" --account-name "$STORAGE_ACCOUNT" --subscription "$SUBSCRIPTION_ID" --query '[0].value' -o tsv)

# Create container if it doesn't exist
echo "Checking blob container..."
az storage container show --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT" --account-key "$ACCOUNT_KEY" 2>/dev/null || \
  az storage container create --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT" --account-key "$ACCOUNT_KEY"

echo "Remote backend resources are ready."
