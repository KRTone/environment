terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
    gitea = {
      source  = "go-gitea/gitea"
      version = "~> 0.6"
    }
  }
}
