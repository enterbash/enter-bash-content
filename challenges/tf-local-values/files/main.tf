terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "config" {
  content  = "project=web-app\nenv=production"
  filename = "${path.module}/web-app-config.txt"
}

resource "local_file" "readme" {
  content  = "# web-app\nEnvironment: production\nManaged by Terraform"
  filename = "${path.module}/web-app-readme.md"
}

resource "local_file" "metadata" {
  content  = "name=web-app\nstage=production\nversion=1.0"
  filename = "${path.module}/web-app-metadata.txt"
}
