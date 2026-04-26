#!/bin/bash
set -e
mkdir -p ~/terraform-project
cd ~/terraform-project

cat > pre.tf << 'TFEOF'
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

resource "random_pet" "server_name" {
  length    = 2
  separator = "-"
}

resource "local_file" "server_config" {
  content  = "server=${random_pet.server_name.id}"
  filename = "${path.module}/server-config.txt"
}
TFEOF

terraform init -input=false > /dev/null 2>&1
terraform apply -auto-approve -input=false > /dev/null 2>&1
rm -f pre.tf
