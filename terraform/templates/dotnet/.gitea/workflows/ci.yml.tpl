name: .NET CI/CD

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

env:
  IMAGE_NAME: ${image_name}
  K8S_NAMESPACE: ${k8s_namespace}
  REGISTRY_PUSH_ADDRESS: ${registry_push_address}
  DOCKER_NETWORK: ${docker_network_name}
  KUBECONFIG_HOST_PATH: ${kubeconfig_runner_path}
  GITEA_GIT_URL: http://oauth2:$${{ github.token }}@${gitea_host}:${gitea_port}/$${{ github.repository }}.git

jobs:
  test:
    runs-on: ${runner_label}
    container:
      image: mcr.microsoft.com/dotnet/sdk:8.0
    steps:
      - name: Clone repository
        run: |
          git config --global --add safe.directory '*'
          git init
          git remote add origin "$${{ env.GITEA_GIT_URL }}"
          git fetch --depth=1 origin "$${{ github.sha }}"
          git checkout FETCH_HEAD

      - name: Restore
        run: dotnet restore DotNetApp.sln

      - name: Test
        run: dotnet test DotNetApp.sln --no-restore --configuration Release

  build-image:
    runs-on: ${runner_label}
    needs: test
    if: github.event_name == 'push'
    container:
      image: docker:24-cli
    steps:
      - name: Clone repository
        run: |
          apk add --no-cache git
          git config --global --add safe.directory '*'
          git init
          git remote add origin "$${{ env.GITEA_GIT_URL }}"
          git fetch --depth=1 origin "$${{ github.sha }}"
          git checkout FETCH_HEAD

      - name: Build Docker image
        run: |
          docker build -t $${{ env.IMAGE_NAME }}:$${{ github.sha }} .
          docker tag $${{ env.IMAGE_NAME }}:$${{ github.sha }} $${{ env.IMAGE_NAME }}:latest

  deploy:
    runs-on: ${runner_label}
    needs: build-image
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master'
    container:
      image: docker:24-cli
    steps:
      - name: Clone repository
        run: |
          apk add --no-cache git curl
          git config --global --add safe.directory '*'
          git init
          git remote add origin "$${{ env.GITEA_GIT_URL }}"
          git fetch --depth=1 origin "$${{ github.sha }}"
          git checkout FETCH_HEAD

      - name: Deploy to Kubernetes
        run: |
          set -e
          registry="$${{ env.REGISTRY_PUSH_ADDRESS }}"
          if [ -z "$registry" ]; then
            echo "ERROR: REGISTRY_PUSH_ADDRESS is empty — add to ci.yml env:"
            echo "  REGISTRY_PUSH_ADDRESS: host.docker.internal:30500"
            exit 1
          fi
          kubeconfig_host="$${{ env.KUBECONFIG_HOST_PATH }}"
          if [ -z "$kubeconfig_host" ]; then
            echo "ERROR: KUBECONFIG_HOST_PATH is empty — add path from: terraform output -raw kubeconfig_runner_path"
            exit 1
          fi
          k8s_ns="$${{ env.K8S_NAMESPACE }}"

          echo "Pushing $${{ env.IMAGE_NAME }} to $registry"
          docker tag $${{ env.IMAGE_NAME }}:latest "$registry/$${{ env.IMAGE_NAME }}:latest"
          docker push "$registry/$${{ env.IMAGE_NAME }}:latest"

          for mf in k8s/namespace.yaml k8s/deployment.yaml k8s/service.yaml; do
            echo "Applying $mf"
            docker run --rm -i --network "$${{ env.DOCKER_NETWORK }}" \
              -v "$kubeconfig_host:/kube/config:ro" \
              bitnami/kubectl:latest --kubeconfig /kube/config apply -f - < "$mf"
          done

          docker run --rm --network "$${{ env.DOCKER_NETWORK }}" \
            -v "$kubeconfig_host:/kube/config:ro" \
            bitnami/kubectl:latest --kubeconfig /kube/config \
            -n "$k8s_ns" rollout status "deployment/$${{ env.IMAGE_NAME }}" --timeout=120s
