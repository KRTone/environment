log:
  level: info

runner:
  file: .runner
  capacity: 1

container:
  network: ${network_name}
  valid_volumes:
    - /var/run/docker.sock
