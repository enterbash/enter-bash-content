# Solution: Recover Deleted File

## What the validator checks

- **Check that config.json exists**: /home/runner/app/config.json does not exist
- **Check that it has the correct content**: config.json does not contain expected content
- config.json is missing expected fields

## Solution

```bash
# The file was deleted but a process still has it open.
# Find the process holding it:
lsof | grep config.json

# Get PID and file descriptor number from the output, then recover:
PID=$(lsof | grep config.json | awk '{print $2}' | head -1)
FD=$(lsof -p $PID | grep config.json | awk '{print $4}' | tr -d 'rw')

# Copy the file back from /proc
cp /proc/$PID/fd/$FD /home/runner/app/config.json
```

Linux keeps file data alive as long as any process has an open file descriptor, even after `unlink()`. `/proc/PID/fd/` exposes those descriptors.
