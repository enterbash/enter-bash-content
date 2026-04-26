# Solution: Fix Disk Mount Permissions

## Approach

Fix the mount permissions so the runner user can access the data directory.

```bash
# Check current permissions
ls -la /mnt/data

# Fix ownership and permissions
sudo chown runner:runner /mnt/data
sudo chmod 755 /mnt/data

# Verify
ls -la /mnt/data
touch /mnt/data/test.txt && echo "Write access OK"
```

## Why this works

The directory was created as root-owned with `700` permissions. Changing ownership to `runner` and setting `755` allows the user to read, write, and execute.
