# Solution: Use Provisioners

## Solution

```hcl
resource "null_resource" "app_setup" {
  provisioner "local-exec" {
    command = "echo 'Provisioning...' && mkdir -p ${path.module}/app"
  }

  provisioner "local-exec" {
    command = "echo 'app=myapp' > ${path.module}/app/config.txt"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${path.module}/app"
  }
}
```

> **Note:** Provisioners are a last resort. Prefer native Terraform resources when possible.

## Why this works

`local-exec` runs commands on the machine running Terraform. Multiple provisioners run in order. `when = destroy` runs during `terraform destroy`. Provisioners don't track state — they run once on create.
