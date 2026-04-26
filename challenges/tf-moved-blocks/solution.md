# Solution: Use Moved Blocks for Refactoring

## Approach

Use `moved` blocks to rename resources without destroying them.

```hcl
# Add to main.tf
moved {
  from = local_file.old_config
  to   = local_file.new_config
}

# Rename the resource block
resource "local_file" "new_config" {  # was "old_config"
  content  = "app=myapp\n"
  filename = "${path.module}/config.txt"
}
```

```bash
terraform plan   # should show "1 to move, 0 to add, 0 to destroy"
terraform apply -auto-approve
```

## Why this works

`moved` blocks tell Terraform that a resource was renamed. Without it, Terraform would destroy the old resource and create a new one. With it, the state entry is simply renamed.
