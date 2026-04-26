terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# BUG: These variables have incorrect type constraints. Fix them!

# Should be a string, not a number
variable "app_name" {
  type    = number
  default = "my-application"
}

# Should be a number, not a string
variable "port" {
  type    = string
  default = 8080
}

# Should be a list(string), not a map
variable "allowed_hosts" {
  type    = map(string)
  default = ["localhost", "example.com", "api.example.com"]
}

# Should be an object with name(string) and enabled(bool)
variable "feature_flags" {
  type = list(string)
  default = {
    name    = "dark-mode"
    enabled = true
  }
}

resource "local_file" "config" {
  content  = "app=${var.app_name}\nport=${var.port}\nhosts=${join(",", var.allowed_hosts)}\nfeature=${var.feature_flags.name}"
  filename = "${path.module}/config.txt"
}
