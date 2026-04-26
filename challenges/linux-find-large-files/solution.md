# Solution: Find Large Files

## What the validator checks

- Large files still exist:

## Solution

```bash
# Find files over 100MB
find / -type f -size +100M 2>/dev/null

# Remove them
find / -type f -size +100M -delete 2>/dev/null

# Verify none remain
find / -type f -size +100M 2>/dev/null | wc -l  # should be 0
```

`-size +100M` matches files strictly larger than 100 megabytes.
