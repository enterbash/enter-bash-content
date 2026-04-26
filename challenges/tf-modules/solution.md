# Solution: Create a Simple Module

## What the validator checks

- Expected to find: module 
- Expected to find: source.*modules/config
- Expected to find: app_name
- Expected to find: environment
- Expected to find: variable 
- Expected to find: variable 
- Expected to find: resource 
- Expected to find: output 
- Expected to find: output 
- Expected to find: module\.app_config
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
# modules/config/main.tf
variable "app_name" { type = string }
variable "environment" { type = string }

resource "local_file" "config" {
  content  = "app=${var.app_name}\nenv=${var.environment}\n"
  filename = "${path.module}/app.conf"
}

output "config_path" {
  value = local_file.config.filename
}
```

```hcl
# main.tf
module "app_config" {
  source      = "./modules/config"
  app_name    = "myapp"
  environment = "production"
}
```
