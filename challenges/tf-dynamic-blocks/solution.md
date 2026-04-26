# Solution: Use Dynamic Blocks

## Solution

```hcl
variable "provisioners" {
  type    = list(string)
  default = ["web", "api", "worker"]
}

resource "null_resource" "app" {
  dynamic "provisioner" {
    for_each = var.provisioners
    content {
      # provisioner.value is the current item
    }
  }
}

# More practical example with local_file
resource "local_file" "configs" {
  for_each = toset(var.provisioners)
  content  = "provisioner=${each.value}\n"
  filename = "${path.module}/${each.value}.conf"
}
```

## Why this works

`dynamic` blocks generate repeated nested blocks from a list or map. `for_each` iterates the collection; `content` defines the block body. `provisioner.value` (or the iterator name) accesses the current item.
