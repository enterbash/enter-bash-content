# Solution: Manage Disk Space

## What the validator checks

- Old log files still exist in /var/log/myapp/
- **Check that build cache is cleaned**: /tmp/build-cache still has significant data
- Old .deb files still in /home/runner/downloads/

## Solution

```bash
# Remove old log files
find /var/log/myapp -name "*.log.old" -delete

# Clean build cache
rm -rf /tmp/build-cache/*

# Remove old downloads
find /home/runner/downloads -name "*.deb" -delete

# Verify
df -h
```
