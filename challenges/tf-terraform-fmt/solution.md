# Solution: Fix Terraform Formatting

## What the validator checks


## Solution

```bash
cd ~/terraform-project
terraform fmt

# Verify it's now formatted
terraform fmt -check   # exits 0 if already formatted
```

`terraform fmt` enforces canonical HCL style: 2-space indentation, aligned `=` signs, consistent spacing.
