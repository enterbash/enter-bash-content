# Solution: Use Terraform Workspaces

## Approach

Create a `staging` workspace and use `terraform.workspace` in the config.

```bash
cd ~/terraform-project

# Create and switch to staging workspace
terraform workspace new staging
terraform workspace list  # should show staging

# Update main.tf to use workspace
```

```hcl
resource "local_file" "env_config" {
  content  = "environment=${terraform.workspace}\n"
  filename = "${path.module}/env.conf"
}
```

```bash
terraform apply -auto-approve
cat env.conf  # should show "environment=staging"
```

## Why this works

Workspaces let you manage multiple environments with the same config. `terraform.workspace` returns the current workspace name. Each workspace has its own state file.
