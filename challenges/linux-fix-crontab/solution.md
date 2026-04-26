# Solution: Fix Broken Crontab

## Approach

Make `backup.sh` executable, add the correct cron entry, and verify the script creates the backup file.

```bash
# Make backup script executable
chmod +x /home/runner/backup.sh

# Add cron job — runs at 2AM daily
(crontab -l 2>/dev/null; echo "0 2 * * * /home/runner/backup.sh") | crontab -

# Verify it was added
crontab -l
```

## Why this works

The cron expression `0 2 * * *` means: minute 0, hour 2, every day, every month, every weekday — i.e. 2:00 AM daily. The validate checks for `^0 2 \* \* \*` at the start of the line.
