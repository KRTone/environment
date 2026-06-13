# DotNetApp

Пример .NET 8 Web API с CI/CD через Gitea Actions.

Репозиторий **не создаётся Terraform** — разверните вручную из этого шаблона.

## Создание репозитория в Gitea

1. Создайте репозиторий в Gitea (например `admin/dotnet-app`).
2. Скопируйте содержимое шаблона (кроме `.tpl`-файлов — их нужно отрендерить).
3. Отрендерите `.gitea/workflows/ci.yml.tpl` → `.gitea/workflows/ci.yml`.
4. Отрендерите `k8s/*.yaml` — замените `${image_name}`, `${k8s_namespace}`, `${k8s_node_port}`, `${registry_address}`.
5. `git init`, commit, push в Gitea.

### Gitea Secrets (обязательно для deploy)

По аналогии с [actions-hub/kubectl](https://github.com/actions-hub/kubectl): kubeconfig передаётся **целиком** в secret `KUBE_CONFIG` (base64).

После `terraform apply`:

```powershell
cd terraform
terraform output -raw kubeconfig_runner_base64
```

**Gitea → репозиторий → Settings → Secrets → Actions:**

| Secret | Значение |
|--------|----------|
| `KUBE_CONFIG` | вывод `terraform output -raw kubeconfig_runner_base64` |
| `KUBE_CONTEXT` | опционально, например `k3d-local` (если в kubeconfig несколько контекстов) |

Или вручную (PowerShell):

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("terraform/.generated/kubeconfig-local-runner"))
```

Файл `kubeconfig-local-runner` содержит `server: https://k3d-local-server-0:6443` — для job-контейнеров в `gitea-network`.

### Переменные для ci.yml.tpl

| Переменная | Пример |
|------------|--------|
| `image_name` | `dotnet-app` |
| `k8s_namespace` | `apps` |
| `k8s_node_port` | `30080` |
| `registry_push_address` | `host.docker.internal:30500` |
| `registry_address` | `docker-registry:5000` — только для `k8s/deployment.yaml` |
| `docker_network_name` | `gitea-network` |
| `runner_label` | `self-hosted` |
| `gitea_host` | `gitea` |
| `gitea_port` | `3000` |

### Docker Desktop

В **Settings → Docker Engine**:

```json
"insecure-registries": ["host.docker.internal:30500"]
```

## Pipeline

1. **test** — `dotnet test`
2. **build-image** — сборка Docker-образа на runner
3. **deploy** — push в registry, `kubectl apply` (kubeconfig из `secrets.KUBE_CONFIG`)

## Локальный запуск

```powershell
dotnet run --project src/DotNetApp
```

## Kubernetes

```powershell
kubectl --kubeconfig terraform/.generated/kubeconfig-local get pods -n apps
kubectl --kubeconfig terraform/.generated/kubeconfig-local port-forward svc/dotnet-app 8080:8080 -n apps
```

Откройте `/health` через `kubectl port-forward`.
