# Solution: Debug File Permissions

## What the validator checks

- **Check deploy.sh is executable**: deploy.sh is not executable
- **Check config.txt is readable**: config.txt is not readable
- **Check logs dir is writable**: logs/ directory is not writable
- **Check deploy log exists (script was run)**: deploy.log not found — run the deploy script

## Solution

```bash
# Check current permissions
ls -la /home/runner/app/

# Fix ownership and permissions
chmod 755 /home/runner/app
chmod 644 /home/runner/app/*.conf 2>/dev/null || true
chmod +x /home/runner/app/*.sh 2>/dev/null || true
```
