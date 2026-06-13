moved {
  from = docker_image.registry[0]
  to   = module.registry[0].docker_image.registry
}

moved {
  from = docker_container.registry[0]
  to   = module.registry[0].docker_container.registry
}
