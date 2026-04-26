# Solution: Fix String Interpolation

## Solution

```hcl
variable "app_name" { default = "myapp" }
variable "environment" { default = "production" }
variable "version" { default = "1.0.0" }

locals {
  full_name = "${var.app_name}-${var.environment}"
  tag       = "v${var.version}"
}

resource "local_file" "config" {
  content  = <<-EOT
    app_name    = ${var.app_name}
    environment = ${var.environment}
    full_name   = ${local.full_name}
    tag         = ${local.tag}
  EOT
  filename = "${path.module}/config.txt"
}
```

## Why this works

`"${expression}"` interpolates values into strings. `<<-EOT ... EOT` is a heredoc (strips leading whitespace). String functions like `upper()`, `lower()`, `format()` work inside interpolations.
