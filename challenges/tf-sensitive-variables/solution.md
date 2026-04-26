# Solution: Handle Sensitive Variables

## What the validator checks

- db_password variable should have sensitive = true
- api_key variable should have sensitive = true
- Expected to find: output "app_id"
- Expected to find: output "password_set"
- password_set output should have sensitive = true
- Expected to find: local_file.*config
- terraform plan shows pending changes — your config may be incomplete

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
  description = "Number of config files"
  type        = number
  default     = 3
}

resource "local_file" "config" {
  count    = var.file_count
  content  = "project=${var.project_name}\nenv=${var.environment}\n"
  filename = "${path.module}/config-${count.index}.txt"
}
```

```bash
terraform apply -auto-approve
```
