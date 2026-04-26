# Solution: Add Variable Validation Rules

## Solution

```hcl
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "port" {
  type = number
  validation {
    condition     = var.port >= 1024 && var.port <= 65535
    error_message = "Port must be between 1024 and 65535."
  }
}

variable "app_name" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.app_name))
    error_message = "App name must start with a letter and contain only lowercase letters, numbers, and hyphens."
  }
}
```

## Why this works

`validation` blocks run before any resources are created. `condition` is a boolean expression. `error_message` is shown when validation fails. `can()` returns false instead of erroring if the expression fails.
