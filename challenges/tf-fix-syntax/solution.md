# Solution: Fix Terraform Syntax Errors

## What the validator checks


## Solution

The broken `main.tf` has a missing closing brace `}`. Find it and fix it:

```bash
cd ~/terraform-project
terraform validate 2>&1   # shows the exact line with the error
```

```hcl
# main.tf — fixed (add the missing closing brace)
resource "local_file" "config" {
  content  = "app=myapp"
  filename = "${path.module}/config.txt"
}   # ← this was missing
```

```bash
terraform validate   # must pass
```
