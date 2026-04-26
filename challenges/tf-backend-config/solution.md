# Solution: Configure Terraform Backend

## What the validator checks

- Expected to find: backend 
- Expected to find: state/terraform.tfstate
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
terraform {
  required_providers {
    local = { source = "hashicorp/local"; version = "~> 2.0" }
  }
  backend "local" {
    path = "state/terraform.tfstate"
  }
}
```

```bash
terraform init   # re-init to configure the backend
terraform apply -auto-approve
ls state/        # tfstate file should be here
```
