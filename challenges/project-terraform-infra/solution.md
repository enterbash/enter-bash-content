# Solution: Build a Multi-Environment Infrastructure

## What the validator checks

- ~/infra/modules/app-config/main.tf not found — create the module
- ~/infra/modules/app-config/variables.tf not found
- ~/infra/modules/app-config/outputs.tf not found
- ~/infra/main.tf not found
- main.tf should use a module block
- main.tf should reference terraform.workspace for the environment
- 'staging' workspace not found — run: terraform workspace new staging
- 'production' workspace not found — run: terraform workspace new production
- staging workspace has unapplied changes — run: terraform apply -auto-approve
- production workspace has unapplied changes — run: terraform apply -auto-approve
- modules/app-config/outputs.tf should define at least one output

## Solution

```bash
cd ~/terraform-project
terraform init
terraform validate
terraform apply -auto-approve
```

**Fix:** ~/infra/modules/app-config/main.tf not found — create the module

**Fix:** ~/infra/modules/app-config/variables.tf not found

**Fix:** ~/infra/modules/app-config/outputs.tf not found

**Fix:** ~/infra/main.tf not found

**Fix:** main.tf should use a module block

**Fix:** main.tf should reference terraform.workspace for the environment

**Fix:** 'staging' workspace not found — run: terraform workspace new staging

**Fix:** 'production' workspace not found — run: terraform workspace new production

**Fix:** staging workspace has unapplied changes — run: terraform apply -auto-approve

**Fix:** production workspace has unapplied changes — run: terraform apply -auto-approve

**Fix:** modules/app-config/outputs.tf should define at least one output
