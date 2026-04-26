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

# TODO: Add lifecycle rules to this resource:
# - create_before_destroy = true
# - ignore_changes for the "content" attribute
resource "local_file" "config" {
  content  = "version=1.0"
  filename = "${path.module}/config.txt"
}

# TODO: Add lifecycle rule to prevent destruction:
# - prevent_destroy = true
resource "random_pet" "protected" {
  length    = 2
  separator = "-"
}
