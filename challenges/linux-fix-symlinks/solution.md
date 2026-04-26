# Solution: Fix Broken Symlinks

## Approach

Fix each broken symlink to point to the correct target in `current/` instead of the deleted `old/` directory.

```bash
# Check which symlinks are broken
ls -la /home/runner/myapp/

# Fix each one
ln -sf /home/runner/myapp/current/config.env /home/runner/myapp/config.env
ln -sf /home/runner/myapp/current/start.sh   /home/runner/myapp/start.sh
ln -sf /home/runner/myapp/current/version.txt /home/runner/myapp/version.txt
ln -sf /home/runner/myapp/current/lib        /home/runner/myapp/lib

# Verify
ls -la /home/runner/myapp/
```

## Why this works

`ln -sf` creates a symbolic link, overwriting any existing one (`-f`). The target must be an absolute path or relative to the symlink's location.
