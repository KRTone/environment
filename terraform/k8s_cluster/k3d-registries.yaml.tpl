mirrors:
  "${registry_address}":
    endpoint:
      - "http://${registry_address}"
configs:
  "${registry_address}":
    tls:
      insecure_skip_verify: true
