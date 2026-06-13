# DotNetApp

Пример .NET 8 Web API с CI/CD через Gitea Actions.

Репозиторий **не создаётся Terraform** — разверните вручную из этого шаблона.

## Создание репозитория в Gitea

1. Создайте репозиторий в Gitea (например `admin/dotnet-app`).
2. Скопируйте содержимое шаблона (кроме `.tpl`-файлов — их нужно отрендерить).
3. Отрендерите `.gitea/workflows/ci.yml.tpl` → `.gitea/workflows/ci.yml` (подставьте переменные ниже).
4. Отрендерите `k8s/*.yaml` — замените `${image_name}`, `${k8s_namespace}`, `${k8s_node_port}`, `${registry_address}`.
5. `git init`, commit, push в Gitea.

### Переменные для ci.yml.tpl

| Переменная | Пример |
|------------|--------|
| `image_name` | `dotnet-app` |
| `k8s_namespace` | `apps` |
| `k8s_node_port` | `30080` |
| `registry_push_address` | `host.docker.internal:30500` (из `terraform output -raw registry_push_address`) |
| `kubeconfig_runner_path` | `C:/Users/.../terraform/.generated/kubeconfig-local-runner` (из `terraform output -raw kubeconfig_runner_path`) |
| `registry_address` | `docker-registry:5000` — только для `k8s/deployment.yaml` (pull) |
| `docker_network_name` | `gitea-network` |
| `runner_label` | `self-hosted` |
| `gitea_host` | `gitea` |
| `gitea_port` | `3000` |

Перед deploy установите [k3d](https://k3d.io/stable/#installation) и выполните `terraform apply` (Gitea + runner + registry + k3d в `gitea-network`).

## Pipeline

1. **test** — `dotnet test`
2. **build-image** — сборка Docker-образа на runner
3. **deploy** — push в `host.docker.internal:30500`, `kubectl apply` через nested `docker run` (kubeconfig с хоста)

## Локальный запуск

```powershell
dotnet run --project src/DotNetApp
```

## Kubernetes

После deploy (из контейнера в `gitea-network` или через port-forward):

```powershell
kubectl --kubeconfig terraform/.generated/kubeconfig-local get pods -n apps
kubectl --kubeconfig terraform/.generated/kubeconfig-local port-forward svc/dotnet-app 8080:8080 -n apps
```

Откройте `/health` через `kubectl port-forward` (см. README шаблона).
