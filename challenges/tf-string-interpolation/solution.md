# Solution: Fix String Interpolation

## What the validator checks

- Expected to find: ${var.project}
- Expected to find: ${var.region}
- Expected to find: ${random_id.suffix.hex}
- Expected to find: ${path.module}
- Found bare \$var. references without \${}
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
variable "app_name" { default = "myapp" }
variable "environment" { default = "production" }

locals {
  full_name = "${var.app_name}-${var.environment}"
}

resource "local_file" "config" {
  content  = "app=${var.app_name}\nenv=${var.environment}\nfull=${local.full_name}\n"
  filename = "${path.module}/config.txt"
}
```
