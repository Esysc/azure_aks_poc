#!/bin/bash

# This script cleans up remote Terraform state and storage resources after 'terraform destroy'.
# It automatically retrieves resource group and other outputs from Terraform.

set -e

cd "$(dirname "$0")/terraform"


# Hardcoded backend values (keep in sync with main.tf backend block)
RESOURCE_GROUP="rg-aks-poc"
STORAGE_ACCOUNT="pocstorageaccount"
CONTAINER="tfstatestore"
STATE_FILE="terraform.tfstate"

# Print only the state file name (other values are well-known and hardcoded)
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
