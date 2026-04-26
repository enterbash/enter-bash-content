# Solution: Fix Terraform Drift

## What the validator checks

- Terraform plan shows changes

## Solution

```bash
cd ~/terraform-project

# See what drifted
terraform plan

# Option 1: restore to match Terraform state (overwrites manual change)
terraform apply -auto-approve

# Option 2: update config to match the drift, then apply
```

Terraform detects drift by comparing state against actual files. `apply` reconciles them.
