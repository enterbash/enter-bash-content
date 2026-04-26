terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "config" {
  content  = "project=my-app\nenvironment=staging"
  filename = "${path.module}/config.txt"
}

resource "local_file" "docs" {
  count    = 3
  content  = "Document ${count.index} for my-app"
  filename = "${path.module}/doc-${count.index}.txt"
}
