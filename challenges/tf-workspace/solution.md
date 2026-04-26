# Solution: Use Terraform Workspaces

## What the validator checks

- Expected to find: terraform.workspace
- 'staging' workspace not found — run: terraform workspace new staging

## Solution

```bash
cd ~/terraform-project
terraform workspace new staging
terraform workspace list   # should show staging
```

Update `main.tf` to use `terraform.workspace`:
```hcl
resource "local_file" "env_config" {
  content  = "environment=${terraform.workspace}\n"
  filename = "${path.module}/env.conf"
}
```

```bash
terraform apply -auto-approve
cat env.conf   # should show "environment=staging"
```
