terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# TODO: Call the module from ./modules/config
# Pass these variables:
#   app_name    = "my-service"
#   environment = "production"

# TODO: Create an output "config_file" that references the module's output
