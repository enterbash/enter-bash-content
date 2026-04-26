# Solution: Fix Dependency Ordering

## Solution

```hcl
resource "null_resource" "create_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/output"
  }
}

resource "local_file" "app_config" {
  content  = "app=myapp\n"
  filename = "${path.module}/output/app.conf"

  depends_on = [null_resource.create_dir]
}

resource "local_file" "readme" {
  content  = "README\n"
  filename = "${path.module}/output/README.txt"

  depends_on = [local_file.app_config]
}
```

## Why this works

`depends_on` creates explicit ordering when Terraform can't infer it from references. Without it, Terraform might try to create `app_config` before the directory exists.
