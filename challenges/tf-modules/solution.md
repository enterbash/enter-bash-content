# Solution: Create a Simple Module

## Solution

```hcl
# modules/config/main.tf
variable "app_name" {
  type = string
}

variable "environment" {
  type = string
}

resource "local_file" "config" {
  content  = "app=${var.app_name}\nenv=${var.environment}\n"
  filename = "${path.module}/app.conf"
}

output "config_path" {
  value = local_file.config.filename
}
```

```hcl
# main.tf (root)
module "app_config" {
  source      = "./modules/config"
  app_name    = "myapp"
  environment = "production"
}

output "config_file" {
  value = module.app_config.config_path
}
```

## Why this works

Modules encapsulate reusable infrastructure. Input variables are passed as arguments. Outputs expose values to the calling module. `source = "./modules/config"` references a local module.
