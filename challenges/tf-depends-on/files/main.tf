terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# This resource creates a directory
resource "null_resource" "create_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/app-data"
  }
}

# BUG: This resource writes to the directory but doesn't depend on it being created first
# Add depends_on to fix the ordering
resource "local_file" "app_config" {
  content  = "app=myservice\nversion=1.0"
  filename = "${path.module}/app-data/config.txt"
}

# BUG: This resource reads the config but doesn't depend on it being written first
# Add depends_on to fix the ordering
resource "null_resource" "validate_config" {
  provisioner "local-exec" {
    command = "cat ${path.module}/app-data/config.txt"
  }
}
