# DotNetApp

Пример .NET 8 Web API с CI/CD через Gitea Actions.

Репозиторий **не создаётся Terraform** — разверните вручную из этого шаблона.

## Создание репозитория в Gitea

1. Создайте репозиторий в Gitea (например `admin/dotnet-app`).
2. Скопируйте содержимое шаблона (кроме `.tpl`-файлов — их нужно отрендерить).
3. Отрендерите `.gitea/workflows/ci.yml.tpl` → `.gitea/workflows/ci.yml` (подставьте переменные ниже).
4. Отрендерите `k8s/*.yaml` — замените `${image_name}`, `${k8s_namespace}`, `${k8s_node_port}`, `${k8s_registry_node_port}`.
5. `git init`, commit, push в Gitea.

### Переменные для ci.yml.tpl

| Переменная | Пример |
|------------|--------|
| `image_name` | `dotnet-app` |
| `k8s_namespace` | `environment` |
| `k8s_node_port` | `30080` |
| `k8s_registry_node_port` | `30500` (=`terraform output registry_url`) |
| `kubeconfig_host_path` | `C:/Users/you/.kube/config` |
| `runner_label` | `self-hosted` |
| `gitea_host` | `gitea` |
| `gitea_port` | `3000` |

Перед deploy включите Kubernetes в Docker Desktop и выполните `terraform apply` (Gitea + runner + registry).

## Pipeline

1. **test** — `dotnet test`
2. **build-image** — сборка Docker-образа на runner
3. **deploy** — push в registry + `kubectl apply`

## Локальный запуск

```powershell
dotnet run --project src/DotNetApp
```

## Kubernetes

После deploy:

```powershell
kubectl get pods -n environment
kubectl port-forward svc/dotnet-app 8080:8080 -n environment
```

Откройте http://localhost:8080/health
