terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# TODO: Use terraform.workspace to create environment-specific config files
# The file should be named "${path.module}/${terraform.workspace}-config.txt"
# Content should include the workspace name

resource "local_file" "config" {
  content  = "environment=default"
  filename = "${path.module}/default-config.txt"
}
