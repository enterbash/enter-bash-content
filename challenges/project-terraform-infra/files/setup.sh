#!/bin/bash
set -e
mkdir -p ~/infra/modules/app-config
mkdir -p ~/infra/output
cd ~/infra

cat > providers.tf << 'EOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
EOF

terraform init -input=false > /dev/null 2>&1
