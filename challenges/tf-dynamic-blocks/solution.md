# Solution: Use Dynamic Blocks

## What the validator checks

- No dynamic block found — use 'dynamic' keyword
- Expected to find: for_each
- Expected to find: content
- Expected to find: provisioner\.value
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
variable "provisioners" {
  type    = list(string)
  default = ["web", "api", "worker"]
}

resource "local_file" "configs" {
  for_each = toset(var.provisioners)
  content  = "provisioner=${each.value}\n"
  filename = "${path.module}/${each.value}.conf"
}
```

The validator checks that at least one `dynamic` block exists in your `.tf` files.
