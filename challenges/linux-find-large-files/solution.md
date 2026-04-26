# Solution: Find Large Files

## Approach

Use `find` to locate files over 100MB and remove them.

```bash
# Find files over 100MB
find / -type f -size +100M 2>/dev/null

# Remove them (after reviewing)
find / -type f -size +100M -delete 2>/dev/null

# Verify none remain
find / -type f -size +100M 2>/dev/null | wc -l
```

## Why this works

`-size +100M` matches files strictly larger than 100 megabytes. The `2>/dev/null` suppresses permission errors on system directories.
