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

variable "environment" {
  type    = string
  default = "production"
}

resource "random_pet" "server" {
  length    = 2
  separator = "-"
}

resource "local_file" "config" {
  content  = "env=${var.environment}\nserver=${random_pet.server.id}"
  filename = "${path.module}/config.txt"
}
