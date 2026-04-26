terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

variable "services" {
  type = map(object({
    port    = number
    enabled = bool
  }))
  default = {
    web = {
      port    = 8080
      enabled = true
    }
    api = {
      port    = 3000
      enabled = true
    }
    worker = {
      port    = 9090
      enabled = false
    }
  }
}

# TODO: Use for_each to create a config file for each service
# File should be named "${path.module}/<service-name>-config.txt"
# Content should be "service=<name>\nport=<port>\nenabled=<enabled>"
