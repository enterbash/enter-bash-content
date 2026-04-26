# Solution: Use try and can Functions

## Solution

```hcl
variable "config" {
  type    = any
  default = {
    name    = "myapp"
    port    = 8080
    timeout = null
  }
}

locals {
  # try() returns the first successful expression
  app_name = try(var.config.name, "default-app")
  app_port = try(var.config.port, 80)
  timeout  = try(var.config.timeout, 30)  # null falls through to default
}

resource "local_file" "config" {
  content  = "name=${local.app_name}\nport=${local.app_port}\ntimeout=${local.timeout}\n"
  filename = "${path.module}/config.txt"
}
```

## Why this works

`try(expr1, expr2, ...)` evaluates expressions in order and returns the first one that doesn't produce an error. Useful for optional attributes that might be null or missing.
