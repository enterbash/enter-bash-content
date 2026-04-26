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

# Create module directory structure skeleton
mkdir -p ~/terraform-project/modules/config
cat > ~/terraform-project/modules/config/main.tf << 'TFEOF'
# TODO: Define variables, resources, and outputs for this module
# Required variables: app_name, environment
# Required resource: local_file that writes a config file
# Required output: config_path
TFEOF

terraform init -input=false > /dev/null 2>&1
