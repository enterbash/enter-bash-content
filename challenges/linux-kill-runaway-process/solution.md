# Solution: Kill Runaway Process

## Approach

Find the CPU-hogging process and kill it.

```bash
# Find the process
ps aux | grep cpu_hog
# or
pgrep -f cpu_hog

# Kill it
pkill -f cpu_hog

# Verify it's gone
pgrep -f cpu_hog  # should return nothing
```

## Why this works

`pkill -f` matches against the full command line, not just the process name. This reliably kills the background bash script.
