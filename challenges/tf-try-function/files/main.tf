terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

variable "config" {
  type    = any
  default = {
    app = {
      name = "web-service"
    }
  }
}

# TODO: Use try() and can() to safely access config values
locals {
  # Use try() to get app name with fallback "default-app"
  app_name = "TODO"
  # Use try() to get app port with fallback 8080
  app_port = "TODO"
  # Use try() to get database host with fallback "localhost"
  db_host = "TODO"
  # Use can() to check if database config exists
  has_database = false
}

resource "local_file" "config" {
  content  = "app=${local.app_name}\nport=${local.app_port}\ndb=${local.db_host}\nhas_db=${local.has_database}"
  filename = "${path.module}/config.txt"
}
