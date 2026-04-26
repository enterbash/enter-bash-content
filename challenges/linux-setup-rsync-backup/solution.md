# Solution: Set Up rsync Backup

## What the validator checks

- **Check backup script exists and is executable**: /home/runner/run-backup.sh does not exist or is not executable
- **Check script uses rsync**: Backup script does not use rsync
- **Check backup was run (files exist in backup dir)**: Backup missing src/app.js — run the backup script
- Backup missing package.json
- **Check .git is excluded**: .git/ directory should be excluded from backup
- **Check node_modules is excluded**: node_modules/ should be excluded from backup

## Solution

```bash
mkdir -p /home/runner/backup
rsync -av --delete /home/runner/source/ /home/runner/backup/
ls /home/runner/backup/
```

`-a` preserves permissions/timestamps, `--delete` removes files no longer in source.
