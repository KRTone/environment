# Local dev stack

Gitea, Gitea Actions runner, Docker registry, k3d и ArgoCD (GitOps) в `gitea-network`.

Шаблон .NET: `templates/dotnet/`.

**Требования на хосте:** [Docker](https://docs.docker.com/get-docker/) и [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5. Дополнительное ПО (k3d, kubectl, k3s CLI) не нужно — кластер создаётся провайдером `SneakyBugs/k3d`.

Репозитории, проекты и прочие данные в Gitea создаются **вручную** после `terraform apply`.

## Cold start

```powershell
cd terraform
terraform init
terraform apply
```

Затем — репозиторий из `templates/dotnet/` и push в Gitea (см. `templates/dotnet/README.md`).
