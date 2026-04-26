# Solution: Configure Lifecycle Rules

## What the validator checks

- Expected to find: lifecycle
- Expected to find: create_before_destroy.*=.*true
- Expected to find: ignore_changes
- Expected to find: content
- Expected to find: prevent_destroy.*=.*true
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
resource "local_file" "config" {
  content  = "app=myapp\n"
  filename = "${path.module}/config.txt"
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [content]
  }
}
```
