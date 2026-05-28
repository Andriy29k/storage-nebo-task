# Azure Storage Provisioning & Access Control Runbook
---
## Overview

This project provisions and validates a secure Azure Blob Storage environment using role-based access control (RBAC), service principals, encryption at rest, versioning, and diagnostic logging.

The setup demonstrates:

- Secure provisioning of storage resources
- Least-privilege access model using service principals
- Object versioning and soft delete
- Audit logging via Azure Monitor
- Access validation (read/write separation)
---

## Architecture

```
Resource Group
└── Storage Account (StorageV2)
    ├── Blob Container (private access)
    ├── Service Principals
    │   ├── Read-Write SP → Storage Blob Data Contributor
    │   └── Read-Only SP  → Storage Blob Data Reader
    └── Azure Monitor + Log Analytics Workspace
```
---

## Prerequisites

- Azure CLI installed
- Active Azure session (`az login`)
- Permissions to:
  - Create resource groups
  - Create storage accounts
  - Create app registrations/service principals
  - Assign RBAC roles

---

## Environment Configuration

Project uses environment variables loaded from `.env`.

### Example `.env.example`

```bash
RESOURCE_GROUP=rg-storage-lab   #Fill by your values
LOCATION=westeurope

STORAGE_ACCOUNT=mystorageacct123
CONTAINER_NAME=lab-container

TEST_FILE=testfile.txt
DOWNLOAD_PATH=download/

TENANT_ID=<tenant-id>

STORAGE_CONTRIBUTOR_USERNAME=<client-id>
STORAGE_CONTRIBUTOR_PASSWORD=<client-secret>

STORAGE_READER_USERNAME=<client-id>
STORAGE_READER_PASSWORD=<client-secret>

TAGS="project=nebo env=lab owner=devops"
```

Load environment variables:
```bash
set -a
source .env
set +a
```
---
### Storage Provisioning

Script: `storage_creation_script.sh`
What it does:
* Validates Azure CLI availability
* Checks authentication context
* Creates Resource Group
* Creates Storage Account with TLS 1.2 minimum, public blob access disabled, encryption enabled (SSE)
* Enables blob versioning and soft delete (7-day retention)
* Creates private blob container
```bash
bash storage_creation_script.sh
```
---
### Access Model — Service Principals
Read-Write Service Principal

* Role: Storage Blob Data Contributor
* Can: upload, download, delete, list blobs

Read-Only Service Principal

* Role: Storage Blob Data Reader
* Can: list, download blobs
* Cannot: upload or delete blobs

---
### Access Testing Script
Script: `storage_access_tests.sh`
Contributor SP flow:
1. Login as contributor SP
2. Upload blob (initial version)
3. Upload blob again (overwrite → version 2)
4. List blobs
5. Download blob
6. Delete blob

Reader SP flow:

1. Login as reader SP
2. Attempt upload → expected failure
3. List blobs
4. Download blob
5. Attempt delete → expected failure

```bash
bash storage_access_tests.sh
```
---
### Versioning Validation
Blob versioning is enabled at the storage account level. Each overwrite of a blob with the same name creates a new version automatically.
Validation:

1. Upload the same filename twice
2. Verify multiple versions exist:

```bash
az storage blob list \
  --account-name $STORAGE_ACCOUNT \
  --container-name $CONTAINER_NAME \
  --include v \
  --query "[].{Name:name, VersionId:versionId, IsCurrent:isCurrentVersion}" \
  -o table
```
---
### Encryption
Azure Storage automatically encrypts all data at rest using Microsoft-managed keys (SSE) with AES-256. No additional configuration required — enabled by default.
Verify:
```bash
az storage account show \
  --name $STORAGE_ACCOUNT \
  --query encryption
```
Expected: `encryption.enabled = true`

### Diagnostic Settings — Logging
Enable auditing of blob read, write, and delete operations.
Via Azure Portal:
1. Open Storage Account → Monitoring → Diagnostic settings
2. Click + Add diagnostic setting
3. Select logs: BlobRead, BlobWrite, BlobDelete
4. Set destination: Log Analytics Workspace
5. Save

Example Log Analytics query:
```bash
kqlStorageBlobLogs
| where OperationName contains "GetBlob" or OperationName contains "PutBlob"
| project TimeGenerated, OperationName, CallerIpAddress, StatusCode
| order by TimeGenerated desc
```
Note: logs may take 5–15 minutes to appear after initial configuration.

---
### Security Principles Applied
PrincipleImplementation
1. Public access - `disabledallowBlobPublicAccess = false`
2. RBAC authentication - Service principals with scoped roles; no account keys at runtime
3. Least privilege - Separate read-only and read-write identities
4. No secrets in code - `.env` excluded from version control
5. Encryption at rest - `AES-256 SSE`, enabled by default
6. Encryption in transit - `TLS 1.2` minimum enforced
7. Audit logging - Diagnostic settings: BlobRead/Write/Delete
8. Versioning + soft delete - 7-day retention