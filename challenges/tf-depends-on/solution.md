# Solution: Fix Dependency Ordering

## What the validator checks

- Expected to find: depends_on
- depends_on should reference null_resource.create_dir
- depends_on should reference local_file.app_config

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
```
