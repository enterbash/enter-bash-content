terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

variable "config_version" {
  type    = string
  default = "1.0.0"
}

# TODO: Create a null_resource "config_generator" with:
# - triggers = { config_version = var.config_version }
# - local-exec provisioner: echo "Generating config v${var.config_version}" > ${path.module}/config-version.txt

# TODO: Create a null_resource "always_run" with:
# - triggers = { always_run = timestamp() }
# - local-exec provisioner: echo "Run at $(date)" > ${path.module}/last-run.txt
