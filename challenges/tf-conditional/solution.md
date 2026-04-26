# Solution: Use Conditional Expressions

## What the validator checks

- Expected to find: ?
- Expected to find: var\.environment
- Expected to find: var\.enable_debug
- Expected to find: count
- local_file.config resource should reference 'production' in its content
- local_file.debug_log resource should use count
- terraform plan shows pending changes — your config may be incomplete
- terraform plan with staging vars encountered an error

## Solution

```hcl
variable "environment" { default = "production" }
variable "enable_debug" { default = false }

resource "local_file" "config" {
  content  = "environment=${var.environment}\n"
  filename = "${path.module}/config.txt"
}

resource "local_file" "debug_log" {
  count    = var.environment != "production" ? 1 : 0
  content  = "debug mode enabled\n"
  filename = "${path.module}/debug.log"
}
```
