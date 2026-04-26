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

# These resources were renamed from:
#   random_pet.server_name -> random_pet.app_name
#   local_file.server_config -> local_file.app_config
# TODO: Add moved blocks to tell Terraform about the rename
# TODO: Update the resource names and references

resource "random_pet" "server_name" {
  length    = 2
  separator = "-"
}

resource "local_file" "server_config" {
  content  = "server=${random_pet.server_name.id}"
  filename = "${path.module}/server-config.txt"
}
