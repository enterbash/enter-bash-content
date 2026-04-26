# Solution: Fix Terraform Formatting

## Approach

Run `terraform fmt` to auto-format the HCL code.

```bash
cd ~/terraform-project
terraform fmt

# Verify it's now formatted correctly
terraform fmt -check  # exits 0 if already formatted
```

The formatter fixes indentation, alignment, and spacing:
```hcl
# Before (unformatted):
terraform {
required_providers {
local = {
source = "hashicorp/local"

# After (formatted):
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
```

## Why this works

`terraform fmt` is an opinionated formatter — it enforces the canonical HCL style. `-check` mode exits non-zero if any files need formatting, useful in CI.
