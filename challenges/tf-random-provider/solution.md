# Solution: Use the Random Provider

## What the validator checks

- Expected to find: random_pet.*app_name
- Expected to find: random_integer.*port
- Expected to find: random_password.*db_password
- Expected to find: random_uuid.*request_id
- Expected to find: local_file.*config
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
resource "random_pet" "server_name" { length = 2; separator = "-"; prefix = "srv" }
resource "random_integer" "port" { min = 8000; max = 9000 }

resource "local_file" "config" {
  content  = "server=${random_pet.server_name.id}\nport=${random_integer.port.result}\n"
  filename = "${path.module}/config.txt"
}
```
