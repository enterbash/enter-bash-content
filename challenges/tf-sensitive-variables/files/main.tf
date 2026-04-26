terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# TODO: Mark these variables as sensitive
variable "db_password" {
  type    = string
  default = "super-secret-password"
  # Add: sensitive = true
}

variable "api_key" {
  type    = string
  default = "sk-1234567890abcdef"
  # Add: sensitive = true
}

variable "app_name" {
  type    = string
  default = "my-app"
}

resource "random_id" "suffix" {
  byte_length = 4
}

# TODO: Create a local_file "config" that uses the sensitive variables
# The content should include app_name and the random suffix (NOT the secrets)
# filename: "${path.module}/config.txt"

# TODO: Create an output "app_id" with value = "${var.app_name}-${random_id.suffix.hex}"
# TODO: Create an output "password_set" that is sensitive:
#   value = var.db_password != "" ? "yes" : "no"
#   sensitive = true
