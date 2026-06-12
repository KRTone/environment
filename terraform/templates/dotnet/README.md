# DotNetApp

Пример .NET 8 Web API с CI/CD через Gitea Actions.

## Pipeline

1. **test** — `dotnet test`
2. **build-image** — сборка Docker-образа на runner
3. **deploy** — деплой в локальный Kubernetes (Docker Desktop)

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
