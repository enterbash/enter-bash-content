# Solution: Use Local Values

## Solution

```hcl
locals {
  project     = "myapp"
  environment = "production"
  common_tags = {
    project     = local.project
    environment = local.environment
    managed_by  = "terraform"
  }
  config_content = "project=${local.project}\nenv=${local.environment}\n"
}

resource "local_file" "config" {
  content  = local.config_content
  filename = "${path.module}/config.txt"
}

resource "random_pet" "name" {
  prefix = local.project
}
```

## Why this works

`locals` define computed values used multiple times. They reduce repetition and make changes easier — update once, applies everywhere. Reference with `local.name`.
