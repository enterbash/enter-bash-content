# Solution: Use the Random Provider

## Solution

```hcl
resource "random_pet" "server_name" {
  length    = 2
  separator = "-"
  prefix    = "srv"
}

resource "random_integer" "port" {
  min = 8000
  max = 9000
}

resource "random_password" "db_pass" {
  length  = 16
  special = true
}

resource "local_file" "config" {
  content  = "server=${random_pet.server_name.id}\nport=${random_integer.port.result}\n"
  filename = "${path.module}/config.txt"
}
```

## Why this works

The `random` provider generates values that are stable across applies (stored in state). `random_pet` generates human-readable names. `random_password` generates secure passwords.
