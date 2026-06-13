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
  GITEA_GIT_URL: http://oauth2:${{ github.token }}@${gitea_host}:${gitea_port}/${{ github.repository }}.git

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
          git remote add origin "${{ env.GITEA_GIT_URL }}"
          git fetch --depth=1 origin "${{ github.sha }}"
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
          git remote add origin "${{ env.GITEA_GIT_URL }}"
          git fetch --depth=1 origin "${{ github.sha }}"
          git checkout FETCH_HEAD

      - name: Build Docker image
        run: |
          docker build -t "$IMAGE_NAME:${{ github.sha }}" .
          docker tag "$IMAGE_NAME:${{ github.sha }}" "$IMAGE_NAME:latest"

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
          git remote add origin "${{ env.GITEA_GIT_URL }}"
          git fetch --depth=1 origin "${{ github.sha }}"
          git checkout FETCH_HEAD

      - name: Deploy to Kubernetes
        env:
          KUBE_CONFIG: ${{ secrets.KUBE_CONFIG }}
          KUBE_CONTEXT: ${{ secrets.KUBE_CONTEXT }}
        run: |
          set -e
          if [ -z "$REGISTRY_PUSH_ADDRESS" ]; then
            echo "ERROR: REGISTRY_PUSH_ADDRESS is empty — set in ci.yml env (host.docker.internal:30500)"
            exit 1
          fi
          if [ -z "$KUBE_CONFIG" ]; then
            echo "ERROR: secrets.KUBE_CONFIG is empty — add Gitea repository secret (terraform output -raw kubeconfig_runner_base64)"
            exit 1
          fi

          echo "Pushing $IMAGE_NAME to $REGISTRY_PUSH_ADDRESS"
          docker tag "$IMAGE_NAME:latest" "$REGISTRY_PUSH_ADDRESS/$IMAGE_NAME:latest"
          docker push "$REGISTRY_PUSH_ADDRESS/$IMAGE_NAME:latest"

          mkdir -p "$HOME/.kube"
          echo "$KUBE_CONFIG" | base64 -d > "$HOME/.kube/config"
          chmod 600 "$HOME/.kube/config"
          export KUBECONFIG="$HOME/.kube/config"

          curl -fsSLO "https://dl.k8s.io/release/v1.31.4/bin/linux/amd64/kubectl"
          chmod +x kubectl

          if [ -n "$KUBE_CONTEXT" ]; then
            ./kubectl config use-context "$KUBE_CONTEXT"
          fi

          for mf in k8s/namespace.yaml k8s/deployment.yaml k8s/service.yaml; do
            echo "Applying $mf"
            ./kubectl apply -f "$mf"
          done
          ./kubectl -n "$K8S_NAMESPACE" rollout status "deployment/$IMAGE_NAME" --timeout=120s
