# Solution: Use Provisioners

## What the validator checks

- Expected to find: null_resource
- Expected to find: provisioner "local-exec"
- Expected to find: when.*=.*destroy
- Expected to find: provisioned

## Solution

```hcl
resource "null_resource" "app_setup" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/app && echo 'app=myapp' > ${path.module}/app/config.txt"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${path.module}/app"
  }
}
```
