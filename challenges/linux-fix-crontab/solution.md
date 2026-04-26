# Solution: Fix Broken Crontab

## What the validator checks

- **Check that backup script is executable**: backup.sh is not executable
- Crontab does not have correct daily 2AM backup entry
- **Check that backup script runs successfully**: backup.sh does not run successfully
- **Check that backup file was created**: Backup file was not created

## Solution

```bash
# 1. Make the backup script executable
chmod +x /home/runner/backup.sh

# 2. Add the cron entry — runs at 2:00 AM every day
(crontab -l 2>/dev/null; echo "0 2 * * * /home/runner/backup.sh") | crontab -

# 3. Verify
crontab -l

# 4. Run it once to confirm it creates the backup file
bash /home/runner/backup.sh
ls /home/runner/backups/
```

The cron expression `0 2 * * *` means: minute=0, hour=2, every day. The validator checks for `^0 2 * * *` at the start of the crontab line.
