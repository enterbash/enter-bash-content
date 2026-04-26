# Solution: Import Existing Resources

## What the validator checks

- local_file.app_config not found in state — run: terraform import local_file.app_config ~/terraform-project/app-config.txt
- Expected to find: resource 
- terraform plan still shows changes

## Solution

```hcl
# main.tf — add a resource matching the existing file
resource "local_file" "app_config" {
  content  = file("${path.module}/app-config.txt")
  filename = "${path.module}/app-config.txt"
}
```

```bash
cd ~/terraform-project
terraform import local_file.app_config ~/terraform-project/app-config.txt
terraform plan   # should show "No changes"
```
