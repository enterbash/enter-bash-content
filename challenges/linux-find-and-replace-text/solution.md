# Solution: Find and Replace Text in Config Files

## What the validator checks

- **Check no old-server references remain**: old-server.example.com still found in config files
- **Check new-server is present**: new-server.example.com not found in config files
- **Check port 3306 is replaced with 5432**: Port 3306 still found in config files
- Port 5432 not found in config files
- **Check DEBUG is replaced with INFO in .prod.conf files**: DEBUG still found in app.prod.conf
- DEBUG still found in worker.prod.conf

## Solution

```bash
# Replace old hostname with new one in all config files
find /home/runner/configs -name "*.conf" \
  -exec sed -i 's/old-server.example.com/new-server.example.com/g' {} +

# Verify no old references remain
grep -r 'old-server' /home/runner/configs/   # should return nothing
grep -r 'new-server' /home/runner/configs/   # should show all files
```

`sed -i` edits files in-place. `s/old/new/g` replaces all occurrences per line.
