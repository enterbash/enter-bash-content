#!/bin/bash
set -e
mkdir -p ~/terraform-project
cd ~/terraform-project

# Create the file that exists "outside" terraform (the thing to import)
echo "app_version=2.1.0" > app-config.txt

# Pre-create providers.tf so terraform init works offline-ish (cached providers in image)
cat > providers.tf << 'TFEOF'
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
TFEOF

# Run init so providers are downloaded (image has terraform but not provider cache)
terraform init -input=false > /dev/null 2>&1
