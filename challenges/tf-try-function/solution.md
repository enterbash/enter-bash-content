# Solution: Use try and can Functions

## What the validator checks

- Expected to find: try(
- Expected to find: can(
- Expected to find: default-app
- Expected to find: 8080
- Expected to find: localhost
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
variable "config" {
  type    = any
  default = { name = "myapp"; port = 8080; timeout = null }
}

locals {
  app_name = try(var.config.name, "default-app")
  app_port = try(var.config.port, 80)
  timeout  = try(var.config.timeout, 30)
}

resource "local_file" "config" {
  content  = "name=${local.app_name}\nport=${local.app_port}\ntimeout=${local.timeout}\n"
  filename = "${path.module}/config.txt"
}
```

`try()` returns the first expression that doesn't error.
