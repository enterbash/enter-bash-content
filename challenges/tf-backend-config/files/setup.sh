#!/bin/bash
set -e
mkdir -p ~/terraform-project
cd ~/terraform-project
mkdir -p state

cat > main.tf << 'TFEOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
  # TODO: Add backend "local" block here with path = "state/terraform.tfstate"
}

resource "local_file" "config" {
  content  = "app=myapp"
  filename = "${path.module}/app.conf"
}
TFEOF

terraform init -input=false > /dev/null 2>&1
