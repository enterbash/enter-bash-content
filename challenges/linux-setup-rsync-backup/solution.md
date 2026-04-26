# Solution: Set Up rsync Backup

## Approach

Configure and run an rsync backup from source to destination.

```bash
# Create backup destination
mkdir -p /home/runner/backup

# Run rsync backup
rsync -av --delete /home/runner/source/ /home/runner/backup/

# Verify
ls /home/runner/backup/
diff -r /home/runner/source/ /home/runner/backup/
```

## Why this works

`-a` (archive) preserves permissions, timestamps, symlinks. `-v` verbose. `--delete` removes files in destination that no longer exist in source. The trailing `/` on source is important — it copies contents, not the directory itself.
