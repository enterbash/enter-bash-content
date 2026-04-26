terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

variable "environment" {
  type    = string
  default = "production"
}

variable "enable_debug" {
  type    = bool
  default = false
}

# TODO: Create a local_file "config" where:
# - content changes based on environment:
#   if production: "log_level=error\ndebug=false"
#   if not production: "log_level=debug\ndebug=true"
# - filename: "${path.module}/app-config.txt"

# TODO: Create a local_file "debug_log" that is only created
# when var.enable_debug is true (use count conditional)
# - content: "Debug logging enabled"
# - filename: "${path.module}/debug.log"
