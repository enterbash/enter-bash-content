terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# TODO: Create a null_resource with provisioners:
# 1. A local-exec provisioner that creates a file: echo "provisioned" > ${path.module}/provisioned.txt
# 2. A local-exec provisioner with "when = destroy" that removes it
