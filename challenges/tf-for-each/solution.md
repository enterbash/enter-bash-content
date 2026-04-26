# Solution: Use For Each Meta-Argument

## What the validator checks

- Expected to find: for_each
- Expected to find: each.key
- Expected to find: each.value
- Expected to find: var.services

## Solution

```hcl
variable "services" {
  type = map(object({ port = number; env = string }))
  default = {
    web    = { port = 80,   env = "production" }
    api    = { port = 8080, env = "production" }
    worker = { port = 9000, env = "production" }
  }
}

resource "local_file" "service_config" {
  for_each = var.services
  content  = "service=${each.key}\nport=${each.value.port}\n"
  filename = "${path.module}/${each.key}.conf"
}
```
