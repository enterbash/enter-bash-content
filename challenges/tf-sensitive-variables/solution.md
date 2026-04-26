# Solution: Handle Sensitive Variables

## Solution

```hcl
# main.tf
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "my-app"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "staging"
}

variable "file_count" {
  description = "Number of config files to create"
  type        = number
  default     = 3
}

resource "local_file" "config" {
  count    = var.file_count
  content  = "project=${var.project_name}\nenv=${var.environment}\n"
  filename = "${path.module}/config-${count.index}.txt"
}
```

## Why this works

Variables decouple configuration from code. `default` values make them optional. Reference with `var.name`. Override at runtime with `-var` flags or `terraform.tfvars`.
