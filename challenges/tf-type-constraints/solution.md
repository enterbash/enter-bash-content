# Solution: Fix Variable Type Constraints

## What the validator checks

- app_name variable should have type = string
- port variable should have type = number
- allowed_hosts variable should have type = list(string)
- feature_flags variable should have type = object(...)
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
variable "app_name" {
  type    = string
  default = "myapp"
}
variable "port" {
  type    = number
  default = 8080
}
variable "allowed_hosts" {
  type    = list(string)
  default = ["localhost", "example.com"]
}
variable "feature_flags" {
  type = object({ debug = bool; metrics = bool; tracing = bool })
  default = { debug = false; metrics = true; tracing = false }
}
```
