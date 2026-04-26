# Solution: Find and Replace Text in Config Files

## Approach

Use `sed` to replace all occurrences of the old hostname with the new one across all config files.

```bash
# Replace in all .conf files
find /home/runner/configs -name "*.conf" -exec sed -i 's/old-server.example.com/new-server.example.com/g' {} +

# Verify
grep -r 'old-server' /home/runner/configs/  # should return nothing
grep -r 'new-server' /home/runner/configs/  # should show all replacements
```

## Why this works

`sed -i` edits files in-place. The `s/old/new/g` substitution replaces all occurrences on each line. `find -exec` applies it to every `.conf` file.
