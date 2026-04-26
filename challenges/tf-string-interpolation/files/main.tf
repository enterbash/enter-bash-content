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

variable "project" {
  type    = string
  default = "myapp"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

# BUG: String interpolation is broken in these resources. Fix them!
resource "local_file" "config" {
  content  = "project=$var.project\nregion=$var.region\nid=${random_id.suffix}"
  filename = "$path.module/config.txt"
}

resource "local_file" "readme" {
  content  = "# Project: $var.project\nDeployed to: $var.region\nUnique ID: $random_id.suffix.hex"
  filename = "${path.module}/README.md"
}

output "config_content" {
  value = "Config for $var.project in $var.region"
}
