#!/bin/bash
wget -q https://releases.hashicorp.com/terraform/1.9.0/terraform_1.9.0_linux_amd64.zip -O /tmp/tf.zip && unzip -o /tmp/tf.zip -d /usr/local/bin/ && rm /tmp/tf.zip
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
