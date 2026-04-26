# Solution: Fix Locale Settings

## Approach

Generate the missing locale and set it as the system default.

```bash
# Generate the locale
sudo locale-gen en_US.UTF-8

# Set as default
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Apply to current session
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Verify
locale
```

## Why this works

`locale-gen` compiles the locale data. `update-locale` writes to `/etc/default/locale`. The export makes it active in the current shell.
