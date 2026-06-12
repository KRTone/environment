name: .NET CI/CD

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

env:
  IMAGE_NAME: ${image_name}
  K8S_NAMESPACE: ${k8s_namespace}
  KUBECONFIG_HOST: ${kubeconfig_host_path}
  REGISTRY_NODE_PORT: ${k8s_registry_node_port}
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
          apk add --no-cache git
          git config --global --add safe.directory '*'
          git init
          git remote add origin "$${{ env.GITEA_GIT_URL }}"
          git fetch --depth=1 origin "$${{ github.sha }}"
          git checkout FETCH_HEAD

      - name: Deploy to Kubernetes (Docker Desktop)
        run: |
          # kubeconfig с хоста; push образа в Docker registry (NodePort на хосте)
          set -e
          kube_prep='cp /tmp/in/config /tmp/config && sed -i "s/127.0.0.1/host.docker.internal/g" /tmp/config && export KUBECONFIG=/tmp/config && kubectl config set-cluster docker-desktop --tls-server-name=localhost'
          registry="127.0.0.1:$${{ env.REGISTRY_NODE_PORT }}"
          echo "Pushing $${{ env.IMAGE_NAME }} to $registry"
          docker tag $${{ env.IMAGE_NAME }}:latest "$registry/$${{ env.IMAGE_NAME }}:latest"
          docker push "$registry/$${{ env.IMAGE_NAME }}:latest"
          for mf in k8s/namespace.yaml k8s/deployment.yaml k8s/service.yaml; do
            echo "Applying $mf"
            docker run --rm -i --entrypoint /bin/sh \
              -v "$${{ env.KUBECONFIG_HOST }}:/tmp/in/config:ro" \
              bitnami/kubectl:latest \
              -c "$kube_prep && kubectl apply -f -" < "$mf"
          done
          docker run --rm --entrypoint /bin/sh \
            -v "$${{ env.KUBECONFIG_HOST }}:/tmp/in/config:ro" \
            bitnami/kubectl:latest \
            -c "$kube_prep && kubectl -n $${{ env.K8S_NAMESPACE }} rollout status deployment/$${{ env.IMAGE_NAME }} --timeout=120s"
