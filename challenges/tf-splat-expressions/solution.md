# Solution: Use Splat Expressions

## Solution

```hcl
variable "instance_count" {
  default = 3
}

resource "random_pet" "servers" {
  count = var.instance_count
}

# Splat expression — collect all IDs
output "all_server_names" {
  value = random_pet.servers[*].id  # splat: get .id from all instances
}

resource "local_file" "inventory" {
  content  = join("\n", random_pet.servers[*].id)
  filename = "${path.module}/inventory.txt"
}
```

## Why this works

The splat expression `resource[*].attribute` collects an attribute from all instances of a `count`-based resource into a list. Equivalent to `[for r in random_pet.servers : r.id]`.
