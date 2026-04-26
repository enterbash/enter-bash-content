# Solution: Use Conditional Expressions

## Solution

```hcl
variable "environment" {
  type    = string
  default = "production"
}

variable "enable_debug" {
  type    = bool
  default = false
}

resource "local_file" "config" {
  content  = "environment=${var.environment}\ndebug=${var.enable_debug}\n"
  filename = "${path.module}/config.txt"
}

# Conditional resource — only create debug log in non-production
resource "local_file" "debug_log" {
  count    = var.environment != "production" ? 1 : 0
  content  = "debug mode enabled\n"
  filename = "${path.module}/debug.log"
}
```

## Why this works

The ternary operator `condition ? true_val : false_val` works in HCL. Using `count = condition ? 1 : 0` conditionally creates a resource. `var.environment != "production"` evaluates to true/false.
