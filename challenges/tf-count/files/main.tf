terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

variable "environments" {
  type    = list(string)
  default = ["dev", "staging", "prod"]
}

# TODO: Use count to create a local_file for each environment
# Each file should be named "${path.module}/<env>-config.txt"
# Each file should contain "environment=<env>"
resource "local_file" "config" {
  content  = "environment=dev"
  filename = "${path.module}/dev-config.txt"
}
