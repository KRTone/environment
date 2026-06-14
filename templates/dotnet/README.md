# DotNetApp

Пример .NET 8 Web API с GitOps (Gitea Actions + ArgoCD).

## 1. Инфраструктура

```powershell
cd terraform
terraform apply
```

## 2. Репозиторий в Gitea

1. Создайте репозиторий `admin/dotnet-app` (URL = `argocd_app_repo_url` в Terraform).
2. Скопируйте шаблон, отрендерите `.tpl` → `.gitea/workflows/ci.yml`, `k8s/base/*`, `k8s/overlays/dev/kustomization.yaml`.
3. Push в `main`.

### Переменные для `ci.yml.tpl`

| Переменная | Пример |
|------------|--------|
| `image_name` | `dotnet-app` |
| `k8s_namespace` | `apps` |
| `k8s_node_port` | `30080` |
| `registry_push_address` | `host.docker.internal:30500` |
| `registry_address` | `docker-registry:5000` |
| `runner_label` | `self-hosted` |
| `gitea_host` | `gitea` |
| `gitea_port` | `3000` |

### Docker Desktop

```json
"insecure-registries": ["host.docker.internal:30500"]
```

## Pipeline

`test` → `build-image` → `deploy` (push образа + commit `newTag` в Git → ArgoCD sync)

## ArgoCD UI

```powershell
terraform -chdir=terraform output argocd_ui_url
terraform -chdir=terraform output -raw argocd_admin_password
```

Логин: `admin`.
