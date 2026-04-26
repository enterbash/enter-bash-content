terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_pet" "server" {
  length    = 2
  separator = "-"
}

resource "random_integer" "priority" {
  min = 1
  max = 100
}

resource "local_file" "config" {
  content  = "server=${random_pet.server.id}\npriority=${random_integer.priority.result}"
  filename = "${path.module}/config.txt"
}
