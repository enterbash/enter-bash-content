terraform {
  # TODO: Configure a local backend that stores state in a specific path
  # Use: backend "local" { path = "state/terraform.tfstate" }

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "config" {
  content  = "backend=configured"
  filename = "${path.module}/config.txt"
}
