resource "local_file" "k3d_registries" {
  content = templatefile("${path.module}/k3d-registries.yaml.tpl", {
    registry_address = var.registry_address
  })
  filename = var.registries_config_path
}

resource "null_resource" "k3d_cluster" {
  triggers = {
    cluster_name       = var.cluster_name
    network_name       = var.network_name
    registry_address   = var.registry_address
    registries_content = local_file.k3d_registries.content
    kubeconfig_path    = var.kubeconfig_path
    api_host_port      = var.api_host_port
    reconcile_script   = "2"
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<-EOT
      $ErrorActionPreference = "Stop"

      if (-not (Get-Command k3d -ErrorAction SilentlyContinue)) {
        Write-Error "k3d не найден в PATH. Установите: https://k3d.io/stable/#installation"
        exit 1
      }

      $clusterName = "${var.cluster_name}"
      $networkName = "${var.network_name}"
      $regConfigPath = "${replace(var.registries_config_path, "\\", "/")}"
      $kubeconfigPath = "${replace(var.kubeconfig_path, "\\", "/")}"
      $kubeconfigRunnerPath = $kubeconfigPath + "-runner"
      $apiServer = "k3d-$clusterName-server-0"
      $apiHostPort = ${var.api_host_port}

      $configDir = Split-Path -Parent $kubeconfigPath
      if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
      }

      $clusters = @(k3d cluster list -o json | ConvertFrom-Json)
      if ($clusters.Count -eq 1 -and $null -eq $clusters[0].name) { $clusters = @() }
      $existing = $clusters | Where-Object { $_.name -eq $clusterName }

      if (-not $existing) {
        Write-Host "Creating k3d cluster '$clusterName' on network '$networkName'"
        k3d cluster create $clusterName `
          --network $networkName `
          --servers 1 `
          --api-port $apiHostPort `
          --registry-config $regConfigPath `
          --kubeconfig-update-default=false `
          --k3s-arg "--tls-san=$apiServer@server:0" `
          --k3s-arg "--tls-san=127.0.0.1@server:0" `
          --wait
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
      } else {
        Write-Host "k3d cluster '$clusterName' already exists, refreshing kubeconfig"
      }

      $kube = (k3d kubeconfig get $clusterName | Out-String).TrimEnd()
      if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($kube)) {
        Write-Error "k3d kubeconfig get failed for cluster '$clusterName'"
        exit 1
      }
      $utf8 = New-Object System.Text.UTF8Encoding $false
      $hostApiUrl = "https://127.0.0.1:" + $apiHostPort
      $kubeHost = [regex]::Replace($kube, '(?m)^(\s*server:\s+)https://\S+', { param($match) $match.Groups[1].Value + $hostApiUrl })
      [System.IO.File]::WriteAllText($kubeconfigPath, $kubeHost, $utf8)

      $apiUrl = "https://" + $apiServer + ":6443"
      $kubeRunner = [regex]::Replace($kube, '(?m)^(\s*server:\s+)https://\S+', { param($match) $match.Groups[1].Value + $apiUrl })
      [System.IO.File]::WriteAllText($kubeconfigRunnerPath, $kubeRunner, $utf8)
    EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["PowerShell", "-Command"]
    command     = <<-EOT
      $ErrorActionPreference = "Continue"
      if (Get-Command k3d -ErrorAction SilentlyContinue) {
        k3d cluster delete "${self.triggers.cluster_name}" 2>$null
      }
      exit 0
    EOT
  }
}
