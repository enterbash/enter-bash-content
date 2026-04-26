terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# This file already exists on disk at ~/terraform-project/app-config.txt
# You need to:
# 1. Write the resource block for it
# 2. Import it into terraform state
# 3. Make sure terraform plan shows no changes
