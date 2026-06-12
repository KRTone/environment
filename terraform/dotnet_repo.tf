resource "null_resource" "dotnet_repo" {
  count = var.create_dotnet_repo ? 1 : 0

  depends_on = [
    module.gitea,
    module.act_runner,
  ]

  triggers = {
    repo_name     = var.dotnet_repo_name
    repo_owner    = var.dotnet_repo_owner
    template_dir  = sha256(join("", [for f in sort(fileset("${path.module}/templates/dotnet", "**")) : filesha256("${path.module}/templates/dotnet/${f}")]))
    workflow      = sha256(local.dotnet_workflow)
    k8s_manifests = sha256(join("", [local.dotnet_k8s_namespace, local.dotnet_k8s_deployment, local.dotnet_k8s_service]))
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    environment = {
      GITEA_URL            = var.gitea_root_url
      GITEA_USER           = var.admin_username
      GITEA_PASS           = var.admin_password
      REPO_OWNER           = var.dotnet_repo_owner
      REPO_NAME            = var.dotnet_repo_name
      TEMPLATE_DIR         = abspath("${path.module}/templates/dotnet")
      WORKFLOW_YML         = local.dotnet_workflow
      K8S_NAMESPACE_YAML   = local.dotnet_k8s_namespace
      K8S_DEPLOYMENT_YAML  = local.dotnet_k8s_deployment
      K8S_SERVICE_YAML     = local.dotnet_k8s_service
    }
    command = <<-EOT
      $ErrorActionPreference = "Stop"

      function Get-BasicAuthHeader {
        param([string]$User, [string]$Pass)
        $token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$User`:$Pass"))
        return @{ Authorization = "Basic $token" }
      }

      $headers = Get-BasicAuthHeader -User $env:GITEA_USER -Pass $env:GITEA_PASS
      $repoApi = "$($env:GITEA_URL)/api/v1/repos/$($env:REPO_OWNER)/$($env:REPO_NAME)"

      try {
        Invoke-RestMethod -Uri $repoApi -Headers $headers -Method Get | Out-Null
        Write-Host "Repository $($env:REPO_OWNER)/$($env:REPO_NAME) already exists"
      } catch {
        $body = @{
          name           = $env:REPO_NAME
          private        = $true
          auto_init      = $false
          default_branch = "main"
        } | ConvertTo-Json
        Invoke-RestMethod -Uri "$($env:GITEA_URL)/api/v1/user/repos" -Headers $headers -Method Post -Body $body -ContentType "application/json"
        Write-Host "Repository $($env:REPO_OWNER)/$($env:REPO_NAME) created"
      }

      $workDir = Join-Path $env:TEMP "gitea-dotnet-$($env:REPO_NAME)"
      if (Test-Path $workDir) {
        Remove-Item -Recurse -Force $workDir
      }
      New-Item -ItemType Directory -Path $workDir | Out-Null

      Get-ChildItem -Path $env:TEMPLATE_DIR -Force | Where-Object {
        $_.Name -notin @('.gitea', 'k8s')
      } | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $workDir -Recurse -Force
      }

      New-Item -ItemType Directory -Path (Join-Path $workDir ".gitea\workflows") -Force | Out-Null
      $utf8NoBom = New-Object System.Text.UTF8Encoding $false
      [System.IO.File]::WriteAllText((Join-Path $workDir ".gitea\workflows\ci.yml"), $env:WORKFLOW_YML, $utf8NoBom)

      New-Item -ItemType Directory -Path (Join-Path $workDir "k8s") -Force | Out-Null
      [System.IO.File]::WriteAllText((Join-Path $workDir "k8s\namespace.yaml"), $env:K8S_NAMESPACE_YAML, $utf8NoBom)
      [System.IO.File]::WriteAllText((Join-Path $workDir "k8s\deployment.yaml"), $env:K8S_DEPLOYMENT_YAML, $utf8NoBom)
      [System.IO.File]::WriteAllText((Join-Path $workDir "k8s\service.yaml"), $env:K8S_SERVICE_YAML, $utf8NoBom)

      Set-Location $workDir
      git init | Out-Null
      git config user.email "terraform@environment.local"
      git config user.name "terraform"
      git branch -M main
      git add .
      git commit -m "Initial commit: .NET app with CI/CD workflow" | Out-Null

      $userEsc = [uri]::EscapeDataString($env:GITEA_USER)
      $passEsc = [uri]::EscapeDataString($env:GITEA_PASS)
      $remote = "$($env:GITEA_URL -replace '://', "://$${userEsc}:$${passEsc}@")/$($env:REPO_OWNER)/$($env:REPO_NAME).git"
      git remote add origin $remote
      git push -u origin main --force
    EOT
  }
}
