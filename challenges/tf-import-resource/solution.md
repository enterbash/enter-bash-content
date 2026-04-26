# Solution: Import Existing Resources

## Approach

Write a `local_file` resource that matches the existing file, then import it.

```hcl
# main.tf — add this resource
resource "local_file" "app_config" {
  content  = file("${path.module}/app-config.txt")
  filename = "${path.module}/app-config.txt"
}
```

```bash
cd ~/terraform-project

# Import the existing file into state
terraform import local_file.app_config ~/terraform-project/app-config.txt

# Verify no changes pending
terraform plan  # should show "No changes"
```

## Why this works

`terraform import` brings existing infrastructure under Terraform management without recreating it. The resource config must match the actual state — otherwise `plan` will show changes.
