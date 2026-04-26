#!/bin/bash
mkdir -p ~/terraform-project

# Pre-create providers.tf and run init so providers are cached
cd ~/terraform-project
cat > providers.tf << 'TFEOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
TFEOF

terraform init -input=false > /dev/null 2>&1
