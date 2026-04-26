# Solution: Add Variable Validation Rules

## What the validator checks

- Expected at least 3 validation blocks in your .tf files
- Expected to find: condition
- Expected to find: error_message
- terraform plan shows pending changes — your config may be incomplete
- Port validation should reject port 80
- Environment validation should reject 'invalid'

## Solution

```hcl
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Must be dev, staging, or production."
  }
}
variable "port" {
  type = number
  validation {
    condition     = var.port >= 1024 && var.port <= 65535
    error_message = "Port must be 1024-65535."
  }
}
variable "app_name" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.app_name))
    error_message = "Must start with a letter, lowercase letters/numbers/hyphens only."
  }
}
```
