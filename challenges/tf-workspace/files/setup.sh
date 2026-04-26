#!/bin/bash
set -e
mkdir -p ~/terraform-project
cd ~/terraform-project

cat > main.tf << 'TFEOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# TODO: Add terraform.workspace usage here
resource "local_file" "env_config" {
  content  = "environment=default"
  filename = "${path.module}/env.conf"
}
TFEOF

terraform init -input=false > /dev/null 2>&1
