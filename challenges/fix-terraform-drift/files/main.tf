resource "local_file" "config" {
  content  = "environment=production"
  filename = "${path.module}/config.txt"
}

resource "local_file" "readme" {
  content  = "# My Project\nThis is managed by Terraform"
  filename = "${path.module}/README.md"
}
