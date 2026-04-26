# Solution: Use null_resource with Triggers

## What the validator checks

- Expected to find: null_resource.*config_generator
- Expected to find: null_resource.*always_run
- Expected to find: triggers
- Expected to find: config_version
- Expected to find: timestamp()
- Expected to find: provisioner 
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
resource "null_resource" "setup" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "echo 'Setup complete' > ${path.module}/setup.log"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${path.module}/setup.log"
  }
}
```
