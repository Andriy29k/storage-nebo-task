#!/bin/bash
set -euo pipefail

echo ""
echo "============================================="
echo "Azure Login to service principal with contributor role"
az login --service-principal \
  --username "$STORAGE_CONTRIBUTOR_USERNAME" \
  --password "$STORAGE_CONTRIBUTOR_PASSWORD" \
  --tenant "$TENANT_ID"
echo ""


echo ""
echo "============================================="
echo "Atempting to upload blob with contributor role"
az storage blob upload \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name "$CONTAINER_NAME" \
  --name "$TEST_FILE" \
  --file "$TEST_FILE" \
  --auth-mode login
echo ""

echo ""
echo "============================================="
echo "Atempting to upload file_v2 blob with contributor role"
az storage blob upload \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name "$CONTAINER_NAME" \
  --name "$TEST_FILE" \
  --file "$TEST_FILE" \
  --overwrite true \
  --auth-mode login
echo ""

echo ""
echo "============================================="
echo "Atempting to list blobs with contributor role"
az storage blob list \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name "$CONTAINER_NAME" \
  --auth-mode login \
  --output table
echo ""

echo ""
echo "============================================="
echo "Atempting to download blob with contributor role"
az storage blob download \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name "$CONTAINER_NAME" \
  --name "$TEST_FILE" \
  --file "$DOWNLOAD_PATH$TEST_FILE" \
  --auth-mode login
echo ""



echo ""
echo "============================================="
echo "Atempting to delete blob with contributor role"
az storage blob delete \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name "$CONTAINER_NAME" \
  --name "$TEST_FILE" \
  --auth-mode login
echo ""



#READER ROLE

echo ""
echo "============================================="
echo "Azure Login to service principal with reader role"
az login --service-principal \
  --username "$STORAGE_READER_USERNAME" \
  --password "$STORAGE_READER_PASSWORD" \
  --tenant "$TENANT_ID"
echo ""


echo ""
echo "============================================="
echo "Atempting to upload blob with reader role"
az storage blob upload \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name "$CONTAINER_NAME" \
  --name "$TEST_FILE" \
  --file "$TEST_FILE" \
  --auth-mode login
echo ""


echo ""
echo "============================================="
echo "Atempting to list blobs with reader role"
az storage blob list \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name "$CONTAINER_NAME" \
  --auth-mode login \
  --output table
echo ""


echo ""
echo "============================================="
echo "Atempting to download blob with reader role"
az storage blob download \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name "$CONTAINER_NAME" \
  --name "$TEST_FILE" \
  --file "$DOWNLOAD_PATH$TEST_FILE" \
  --auth-mode login
echo ""


echo ""
echo "============================================="
echo "Atempting to delete blob with reader role"
az storage blob delete \
  --account-name "$STORAGE_ACCOUNT" \
  --container-name "$CONTAINER_NAME" \
  --name "$TEST_FILE" \
  --auth-mode login
echo ""

az storage container list \
  --account-name "$STORAGE_ACCOUNT" \
  --auth-mode login \
  --output table