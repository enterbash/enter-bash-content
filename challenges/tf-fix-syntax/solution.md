# Solution: Fix Terraform Syntax Errors

## Approach

Fix the HCL syntax error (missing closing brace) and validate.

```hcl
# main.tf — fixed
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "config" {
  content  = "app=myapp"
  filename = "${path.module}/config.txt"
}   # <-- this closing brace was missing

resource "local_file" "readme" {
  content  = "README"
  filename = "${path.module}/README.txt"
}
```

```bash
terraform validate
```

## Why this works

HCL requires every opening `{` to have a matching `}`. The `terraform validate` command checks syntax without making API calls.
