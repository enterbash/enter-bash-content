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

resource "local_file" "config" {
  content  = "app=myapp"
  filename = "${path.module}/config.txt"
  # Missing closing brace below — syntax error

resource "local_file" "readme" {
  content  = "README"
  filename = "${path.module}/README.txt"
}
TFEOF

terraform init -input=false > /dev/null 2>&1 || true
