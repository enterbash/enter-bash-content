# Solution: Configure Terraform Backend

## Solution

```hcl
# main.tf
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
  backend "local" {
    path = "state/terraform.tfstate"
  }
}

resource "local_file" "config" {
  content  = "app=myapp\n"
  filename = "${path.module}/app.conf"
}
```

```bash
terraform init   # re-init to configure the backend
terraform apply -auto-approve
ls state/        # tfstate file should be here
```

## Why this works

The `backend` block configures where state is stored. The `local` backend stores state in a file. Changing the backend requires `terraform init` to migrate existing state.
