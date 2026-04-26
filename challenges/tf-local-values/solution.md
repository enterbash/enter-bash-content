# Solution: Use Local Values

## What the validator checks

- Expected to find: locals
- Expected to find: project_name
- Expected to find: environment
- Expected to find: common_tags
- Expected to find: local.
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
locals {
  project     = "myapp"
  environment = "production"
  config_content = "project=${local.project}\nenv=${local.environment}\n"
}

resource "local_file" "config" {
  content  = local.config_content
  filename = "${path.module}/config.txt"
}
```
