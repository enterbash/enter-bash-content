# Solution: Kill Runaway Process

## What the validator checks

- **Check that cpu_hog process is no longer running**: cpu_hog process is still running

## Solution

```bash
# Find the CPU-hogging process
pgrep -f cpu_hog

# Kill it
pkill -f cpu_hog

# Verify it's gone
pgrep -f cpu_hog  # should return nothing
```

`pkill -f` matches against the full command line.
