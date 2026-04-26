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
  content  = "environment=production\nversion=1.0.0\ndebug=false"
  filename = "${path.module}/app.conf"
}
TFEOF

terraform init -input=false > /dev/null 2>&1
terraform apply -auto-approve -input=false > /dev/null 2>&1

# Simulate drift: manually change the file content outside terraform
echo "environment=production
version=2.0.0
debug=true
manual_change=yes" > app.conf
