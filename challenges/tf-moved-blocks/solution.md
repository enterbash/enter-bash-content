# Solution: Use Moved Blocks for Refactoring

## What the validator checks

- Expected to find: moved
- Expected to find: random_pet.server_name
- Expected to find: random_pet.app_name
- Expected to find: local_file.server_config
- Expected to find: local_file.app_config
- Expected to find: resource "random_pet" "app_name"
- Expected to find: resource "local_file" "app_config"
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
# Add to main.tf
moved {
  from = local_file.old_config
  to   = local_file.new_config
}

resource "local_file" "new_config" {   # renamed from old_config
  content  = "app=myapp\n"
  filename = "${path.module}/config.txt"
}
```

```bash
terraform plan   # shows "1 to move, 0 to add, 0 to destroy"
terraform apply -auto-approve
```
