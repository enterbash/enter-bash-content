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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_pet" "name" {
  length    = 2
  separator = "-"
}

resource "local_file" "config" {
  content  = "environment=production\napp=${random_pet.name.id}"
  filename = "${path.module}/config.txt"
}
TFEOF

terraform init -input=false > /dev/null 2>&1
