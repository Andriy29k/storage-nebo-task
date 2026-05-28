# NEBO Storage — DevOps task

Azure storage provisioning for the **Provision and configure storage services** task.

| Документація | Шлях |
|--------------|------|
| Повний опис (архітектура, RBAC, VM, скріншоти) | [`task/README.md`](task/README.md) |
| Скрипти | [`task/scripts/`](task/scripts/) |

Швидкий старт на VM:

```bash
cd task
# 1) cred на VM: /etc/smbcredentials/neboappsa.cred (див. scripts/smbcredentials.example)
./scripts/mount-fileshare.sh
# 2) після setup-rbac.sh — export AZURE_CLIENT_* і:
./scripts/test-storage-access.sh
```

Секрети не зберігайте в git — див. `.gitignore`.
# storage-nebo-task
