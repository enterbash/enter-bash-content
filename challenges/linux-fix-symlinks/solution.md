# Solution: Fix Broken Symlinks

## What the validator checks

- Broken symlinks found:
- **Check each symlink resolves to correct target**: config.env symlink is broken or missing
- start.sh symlink is broken or missing
- version.txt symlink is broken or missing
- lib symlink is broken or missing

## Solution

```bash
# Check which symlinks are broken
ls -la /home/runner/myapp/

# Fix each broken symlink to point to current/ instead of old/
ln -sf /home/runner/myapp/current/config.env  /home/runner/myapp/config.env
ln -sf /home/runner/myapp/current/start.sh    /home/runner/myapp/start.sh
ln -sf /home/runner/myapp/current/version.txt /home/runner/myapp/version.txt
ln -sf /home/runner/myapp/current/lib         /home/runner/myapp/lib

# Verify — should show -> current/... not -> old/...
ls -la /home/runner/myapp/
```

`ln -sf` creates a symlink, overwriting any existing one (`-f`). The target must exist.
