# Solution: Use Splat Expressions

## What the validator checks

- Expected to find: \[*\]
- Expected to find: output "all_pet_names"
- Expected to find: output "all_file_paths"
- Expected to find: local_file.*summary
- Expected to find: join
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
resource "random_pet" "servers" { count = 3 }

output "all_server_names" {
  value = random_pet.servers[*].id   # splat: collect .id from all instances
}

resource "local_file" "inventory" {
  content  = join("\n", random_pet.servers[*].id)
  filename = "${path.module}/inventory.txt"
}
```
