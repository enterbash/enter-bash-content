# Solution: Define and Use Variables

## What the validator checks

- Expected to find: variable 
- Expected to find: variable 
- Expected to find: variable 
- Expected to find: var\.project_name
- Expected to find: var\.environment
- Expected to find: var\.file_count
- project_name variable should have default = \
- environment variable should have default = \
- file_count variable should have default = 3
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
