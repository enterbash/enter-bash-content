terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

variable "app_name" {
  type    = string
  default = "my-service"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "ports" {
  type = map(number)
  default = {
    http  = 8080
    https = 8443
    grpc  = 9090
  }
}

# TODO: Use templatefile() to render config.tftpl with the variables above
resource "local_file" "config" {
  content  = "TODO: use templatefile function here"
  filename = "${path.module}/app-config.txt"
}
