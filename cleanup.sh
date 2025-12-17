#!/bin/bash

# This script cleans up remote Terraform state and storage resources after 'terraform destroy'.
# It automatically retrieves resource group and other outputs from Terraform.

set -e

cd "$(dirname "$0")/terraform"

# Get subscription ID dynamically
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Hardcoded backend values (keep in sync with main.tf backend block)
RESOURCE_GROUP="rg-aks-tfstate"  # Separate RG for state storage
STORAGE_ACCOUNT="tfstate${SUBSCRIPTION_ID:0:8}"
CONTAINER="tfstatestore"
STATE_FILE="terraform.tfstate"

# Print values
echo "SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo "STORAGE_ACCOUNT: $STORAGE_ACCOUNT"
echo "STATE_FILE: $STATE_FILE"

echo "Deleting remote Terraform state file..."
az storage blob delete \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name "$CONTAINER" \
  --name "$STATE_FILE" \
  --auth-mode login

echo "Deleting storage container..."
az storage container delete \
  --account-name "$STORAGE_ACCOUNT" \
  --name "$CONTAINER" \
  --auth-mode login

echo "Deleting storage account (this will remove all containers/blobs and cannot be undone)..."
az storage account delete --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --yes

# Check for remaining resources in the storage account before deletion
echo "Checking for remaining containers/blobs in storage account..."
CONTAINERS=$(az storage container list --account-name "$STORAGE_ACCOUNT" --auth-mode login --query '[].name' -o tsv)
if [ -n "$CONTAINERS" ]; then
  echo "Warning: The following containers still exist in the storage account:"
  echo "$CONTAINERS"
  for container in $CONTAINERS; do
    BLOBS=$(az storage blob list --account-name "$STORAGE_ACCOUNT" --container-name "$container" --auth-mode login --query '[].name' -o tsv)
    if [ -n "$BLOBS" ]; then
      echo "  Container '$container' contains blobs:"
      echo "$BLOBS" | sed 's/^/    - /'
    else
      echo "  Container '$container' is empty."
    fi
  done
else
  echo "No containers found in the storage account."
fi

echo "Deleting terraform state resource group..."
az group delete --name "$RESOURCE_GROUP" --yes --no-wait

echo "Deleting AKS resource group (if exists)..."
az group delete --name "rg-aks-poc" --yes --no-wait 2>/dev/null || true

echo "Cleaning up NetworkWatcher resource groups..."
az group list --query "[?starts_with(name, 'NetworkWatcher')].name" -o tsv | while read -r rg; do
  echo "  Deleting $rg..."
  az group delete --name "$rg" --yes --no-wait || true
done

echo "Cleanup complete. Resource group deletions are running in the background."
