# Solution: Use For Each Meta-Argument

## Solution

```hcl
variable "services" {
  type = map(object({
    port = number
    env  = string
  }))
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

## Why this works

`for_each` creates one instance per map entry. `each.key` is the map key; `each.value` is the value. Unlike `count`, `for_each` resources are identified by key, not index — safer for additions/removals.
