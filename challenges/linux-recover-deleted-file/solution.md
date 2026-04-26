# Solution: Recover Deleted File

## Approach

The file was deleted but a process still has it open. Find the file descriptor in `/proc` and copy it out.

```bash
# Find the process holding the deleted file open
lsof | grep config.json
# or
ls /proc/*/fd -la 2>/dev/null | grep config.json

# Get the PID and fd number from the output, then recover
PID=$(lsof | grep config.json | awk '{print $2}' | head -1)
FD=$(lsof -p $PID | grep config.json | awk '{print $4}' | tr -d 'r')

# Copy the file content out
cp /proc/$PID/fd/$FD /home/runner/app/config.json
```

## Why this works

Linux keeps file data alive as long as any process has an open file descriptor, even after `unlink()`. The `/proc/PID/fd/` directory exposes those descriptors as symlinks.
