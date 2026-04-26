terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# TODO: Add validation rules to these variables

variable "environment" {
  type    = string
  default = "staging"
  # Add validation: must be one of "dev", "staging", "production"
}

variable "port" {
  type    = number
  default = 8080
  # Add validation: must be between 1024 and 65535
}

variable "app_name" {
  type    = string
  default = "my-app"
  # Add validation: must start with a letter and only contain letters, numbers, and hyphens
}

resource "local_file" "config" {
  content  = "app=${var.app_name}\nenv=${var.environment}\nport=${var.port}"
  filename = "${path.module}/config.txt"
}
