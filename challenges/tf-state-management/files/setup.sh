#!/bin/bash
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

resource "random_pet" "server" {
  length    = 2
  separator = "-"
}

resource "local_file" "config" {
  content  = "server=${random_pet.server.id}"
  filename = "${path.module}/config.txt"
}
TFEOF

terraform init -input=false > /dev/null 2>&1
terraform apply -auto-approve -input=false > /dev/null 2>&1
