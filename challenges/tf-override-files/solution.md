# Solution: Use Override Files

## Solution

Create an override file to change values for a specific environment.

```hcl
# main_override.tf (or any *_override.tf file)
resource "random_pet" "name" {
  length    = 3        # override: change from 2 to 3
  separator = "_"      # override: change separator
}

resource "local_file" "config" {
  content = "environment=development\n"  # override content
}
```

```bash
terraform plan  # override file is automatically loaded
```

## Why this works

Files ending in `_override.tf` or named `override.tf` are loaded last and merge with the main config. They're useful for local development overrides without modifying the main config.
