# Solution: Use null_resource with Triggers

## Solution

```hcl
resource "null_resource" "setup" {
  triggers = {
    always_run = timestamp()  # re-run every apply
  }

  provisioner "local-exec" {
    command = "echo 'Setup complete' > ${path.module}/setup.log"
  }
}

resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${path.module}/setup.log"
  }
}
```

## Why this works

`null_resource` has no real infrastructure — it's a container for `provisioner` blocks. `triggers` controls when it re-runs. `when = destroy` runs the provisioner on `terraform destroy`.
