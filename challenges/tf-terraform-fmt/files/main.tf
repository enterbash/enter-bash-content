terraform {
required_providers {
local = {
source = "hashicorp/local"
version = "~> 2.0"
}
    random = {
source  = "hashicorp/random"
      version = "~> 3.0"
    }
}
}

variable "project_name" {
type = string
    default="my-app"
}

variable "environment" {
  type=string
default = "production"
}

resource "random_pet" "server" {
length = 2
    separator="-"
}

resource "local_file" "config" {
content = "project=${var.project_name}\nenv=${var.environment}\nserver=${random_pet.server.id}"
    filename="${path.module}/config.txt"
}

output "server_name" {
value=random_pet.server.id
}
