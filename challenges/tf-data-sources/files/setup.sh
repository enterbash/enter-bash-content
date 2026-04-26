#!/bin/bash
mkdir -p ~/terraform-project/source
echo "app_name=myservice" > ~/terraform-project/source/config.txt
echo "1.2.3" > ~/terraform-project/source/version.txt

# Pre-create providers.tf and run init so providers are cached
cd ~/terraform-project
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

terraform init -input=false > /dev/null 2>&1
