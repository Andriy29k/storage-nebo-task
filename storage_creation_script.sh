#!/bin/bash
set -euo pipefail

az version > /dev/null 2>&1 || {
  echo "ERROR: Azure CLI not found. Install from https://aka.ms/azure-cli"
  exit 1
}

echo ""
echo "============================================="
echo "Checking Azure login"
az account show --query "{Subscription:name, ID:id}" -o table || {
  echo "ERROR: Not logged in. Run: az login"
  exit 1
}

echo ""
echo "============================================="
echo "Create Resource Group: $RESOURCE_GROUP"
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --tags $TAGS \
  -o table

echo ""
echo "============================================="
echo "Creating Storage Account with encryption and without public access"
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --access-tier Hot \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --encryption-services blob file \
  --tags $TAGS \
  -o table


echo ""
echo "============================================="
echo "Enabling Blob versioning and soft delete"
az storage account blob-service-properties update \
  --account-name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 7 \
  -o table


echo ""
echo "============================================="
echo "Container creaation"
az storage container create \
  --account-name "$STORAGE_ACCOUNT" \
  --name "$CONTAINER_NAME" \
  --public-access off \
  -o table