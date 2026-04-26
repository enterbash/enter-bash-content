# Solution: Use Count Meta-Argument

## What the validator checks

- Expected to find: count
- Expected to find: count.index
- Expected to find: length(var.environments)
- Plan does not show local_file.config[0] — check count and var.environments
- Plan does not show local_file.config[1] — check count and var.environments
- Plan does not show local_file.config[2] — check count and var.environments

## Solution

```hcl
variable "environments" {
  type    = list(string)
  default = ["dev", "staging", "prod"]
}

resource "local_file" "config" {
  count    = length(var.environments)
  content  = "environment=${var.environments[count.index]}\n"
  filename = "${path.module}/config-${var.environments[count.index]}.txt"
}
```

```bash
terraform plan   # should show 3 resources
terraform apply -auto-approve
```
