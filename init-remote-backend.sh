#!/bin/bash
# init-remote-backend.sh
# Creates Azure storage account and container for Terraform remote state if they do not exist.

set -e



# Hardcoded backend values (keep in sync with main.tf backend block)
RESOURCE_GROUP="rg-aks-poc"
LOCATION="westeurope"
STORAGE_ACCOUNT="pocstorageaccount"
CONTAINER_NAME="tfstatestore"

# Print parsed variables and exit for testing
echo "Backend values used for remote state:"
echo "RESOURCE_GROUP: $RESOURCE_GROUP"
echo "LOCATION: $LOCATION"
echo "STORAGE_ACCOUNT: $STORAGE_ACCOUNT"
echo "CONTAINER_NAME: $CONTAINER_NAME"
exit 0

# Create resource group if it doesn't exist
echo "Checking resource group..."
az group show --name "$RESOURCE_GROUP" 2>/dev/null || \
  az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# Create storage account if it doesn't exist
echo "Checking storage account..."
az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" 2>/dev/null || \
  az storage account create --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --location "$LOCATION" --sku Standard_LRS

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group "$RESOURCE_GROUP" --account-name "$STORAGE_ACCOUNT" --query '[0].value' -o tsv)

# Create container if it doesn't exist
echo "Checking blob container..."
az storage container show --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT" --account-key "$ACCOUNT_KEY" 2>/dev/null || \
  az storage container create --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT" --account-key "$ACCOUNT_KEY"

echo "Remote backend resources are ready."
