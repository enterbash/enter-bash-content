# Solution: Work with Terraform State

## Approach

Rename the resource in both the state and the configuration.

```bash
cd ~/terraform-project

# Step 1: rename in state
terraform state mv random_pet.server random_pet.app_server

# Step 2: update main.tf to match
sed -i 's/resource "random_pet" "server"/resource "random_pet" "app_server"/' main.tf
sed -i 's/random_pet\.server\./random_pet.app_server./g' main.tf

# Step 3: verify no changes pending
terraform plan  # should show "No changes"
```

## Why this works

`terraform state mv` renames a resource in the state file without destroying/recreating it. The config must be updated to match, otherwise Terraform sees a deletion and creation.
