# Job-контейнеры подключаются к той же сети, что и Gitea — иначе localhost:3000 недоступен.
log:
  level: info

runner:
  file: .runner
  capacity: 1

container:
  network: ${network_name}
  valid_volumes:
    - /var/run/docker.sock
%{ if mount_kubeconfig && kubeconfig_host_path != "" ~}
  options: --mount type=bind,source=${kubeconfig_host_path},target=/kube/config,readonly
%{ endif ~}
