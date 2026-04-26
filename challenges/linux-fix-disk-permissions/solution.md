# Solution: Fix Disk Mount Permissions

## What the validator checks

- **Check mount point exists and is mounted**: /mnt/data is not mounted
- /mnt/data should be owned by runner, got <value>
- /mnt/data is still restricted to root
- **Check uploads directory exists**: /mnt/data/uploads/ does not exist
- **Check logs directory exists**: /mnt/data/logs/ does not exist
- **Check runner can write**: runner user cannot write to /mnt/data

## Solution

```bash
sudo chown runner:runner /mnt/data
sudo chmod 755 /mnt/data
ls -la /mnt/data
```
