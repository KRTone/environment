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
  REGISTRY_ADDRESS: ${registry_address}
  KUSTOMIZE_OVERLAY: k8s/overlays/dev
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
          apk add --no-cache git
          git config --global --add safe.directory '*'
          git init
          git remote add origin "${{ env.GITEA_GIT_URL }}"
          git fetch origin main
          git checkout main
          git pull origin main

      - name: GitOps deploy
        run: |
          set -e
          SHA="${{ github.sha }}"
          OVERLAY="$KUSTOMIZE_OVERLAY/kustomization.yaml"

          if [ -z "$REGISTRY_PUSH_ADDRESS" ]; then
            echo "ERROR: REGISTRY_PUSH_ADDRESS is empty — set in ci.yml env"
            exit 1
          fi
          if [ ! -f "$OVERLAY" ]; then
            echo "ERROR: $OVERLAY not found — render k8s/overlays/dev from template"
            exit 1
          fi

          echo "Pushing $IMAGE_NAME:$SHA to $REGISTRY_PUSH_ADDRESS"
          docker tag "$IMAGE_NAME:latest" "$REGISTRY_PUSH_ADDRESS/$IMAGE_NAME:$SHA"
          docker push "$REGISTRY_PUSH_ADDRESS/$IMAGE_NAME:$SHA"

          echo "Updating GitOps manifest: $OVERLAY"
          sed -i "s/newTag: .*/newTag: $SHA/" "$OVERLAY"

          git config user.email "actions@gitea.local"
          git config user.name "Gitea Actions"
          git add "$OVERLAY"
          if git diff --staged --quiet; then
            echo "Manifest already at $SHA — nothing to commit"
            exit 0
          fi
          git commit -m "deploy: $IMAGE_NAME@$SHA"
          git push origin main
          echo "ArgoCD will sync from Git (pull-based GitOps)"
