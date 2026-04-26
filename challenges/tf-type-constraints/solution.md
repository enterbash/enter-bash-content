# Solution: Fix Variable Type Constraints

## Solution

```hcl
variable "app_name" {
  type        = string
  description = "Application name"
  default     = "myapp"
}

variable "port" {
  type        = number
  description = "Application port"
  default     = 8080
}

variable "allowed_hosts" {
  type        = list(string)
  description = "Allowed hostnames"
  default     = ["localhost", "example.com"]
}

variable "feature_flags" {
  type = object({
    debug   = bool
    metrics = bool
    tracing = bool
  })
  default = {
    debug   = false
    metrics = true
    tracing = false
  }
}
```

## Why this works

Type constraints catch configuration errors early. `string`, `number`, `bool` are primitives. `list(type)`, `map(type)`, `set(type)` are collections. `object({})` defines a structured type with named attributes.
