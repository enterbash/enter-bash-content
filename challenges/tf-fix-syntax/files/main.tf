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

resource "random_pet" "server" {
  length    = 2
  separator = "-"

resource "local_file" "config" {
  content  = "server_name=${random_pet.server.id}"
  filename = "${path.module}/config.txt"
}

resource local_file "greeting" {
  content  = "Hello, World!
  filename = "${path.module}/greeting.txt"
}

variable "environment" {
  type    = string
  default = production
}
