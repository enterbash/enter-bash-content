# Solution: Use Override Files

## What the validator checks

- Expected to find: development
- Expected to find: random_pet
- Expected to find: length.*=.*3
- Expected to find: separator.*=.*"_"
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
# main_override.tf (or any *_override.tf file)
resource "random_pet" "name" {
  length    = 3        # overrides the value in main.tf
  separator = "_"
}
```

Override files are loaded last and merge with the main config.
