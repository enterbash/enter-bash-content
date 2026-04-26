#!/bin/bash
mkdir -p ~/terraform-project/modules/config

# Pre-create providers.tf and run init so providers are cached
cd ~/terraform-project
cat > providers.tf << 'TFEOF'
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
TFEOF

terraform init -input=false > /dev/null 2>&1
