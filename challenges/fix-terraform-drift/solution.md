# Solution: Fix Terraform Drift

## Approach

Detect the drift and reconcile state with the actual file.

```bash
cd ~/terraform-project

# See what changed
terraform plan  # shows drift between state and actual file

# Option 1: restore the file to match state
terraform apply -auto-approve  # overwrites the manually changed file

# Option 2: update config to match the drift
# Edit main.tf to match the new content, then apply
```

## Why this works

Terraform detects drift by comparing the state file against the actual infrastructure. `terraform apply` reconciles them by updating infrastructure to match the desired config. For file resources, it overwrites the file.
