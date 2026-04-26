# Solution: Work with Terraform State

## What the validator checks

- random_pet.app_server not found in state — run: terraform state mv random_pet.server random_pet.app_server
- main.tf still has 'random_pet "server"' — rename the resource block to 'app_server'
- main.tf still references random_pet.server — update all references to random_pet.app_server
- terraform plan shows pending changes — state and config are out of sync

## Solution

```bash
cd ~/terraform-project

# Step 1: rename in state (no destroy/recreate)
terraform state mv random_pet.server random_pet.app_server

# Step 2: update main.tf to match
sed -i 's/resource "random_pet" "server"/resource "random_pet" "app_server"/' main.tf
sed -i 's/random_pet\.server\./random_pet.app_server./g' main.tf

# Step 3: verify no changes pending
terraform plan   # should show "No changes"
```

`terraform state mv` renames a resource in state without destroying it.
