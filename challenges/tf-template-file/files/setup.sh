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
  }
}
TFEOF

# Create the template file that users will reference
cat > ~/terraform-project/config.tftpl << 'TFTPL'
# Application Configuration
app_name = "${app_name}"
environment = "${environment}"
ports = [
%{ for port in ports ~}
  ${port},
%{ endfor ~}
]
TFTPL

terraform init -input=false > /dev/null 2>&1
