# Solution: Fix Shell Redirections

## Approach

Fix the redirections in `process.sh` — stdout to results file, stderr to errors log, and append (not overwrite) the summary.

```bash
# Edit process.sh to fix redirections
cat > /home/runner/process.sh << 'SCRIPT'
#!/bin/bash
# stdout → results file
echo "Processing started at $(date)" > ~/output/results.txt
echo "Record 1: OK" >> ~/output/results.txt
echo "Record 2: OK" >> ~/output/results.txt
echo "Record 3: OK" >> ~/output/results.txt
echo "Processing complete: 3 records" >> ~/output/results.txt

# stderr → errors log
echo "WARN: Record 4 had missing fields" 2>> ~/output/errors.log
echo "ERROR: Record 5 failed validation" 2>> ~/output/errors.log

# APPEND to summary (not overwrite)
echo "Run completed: $(date) — 3 success, 1 warn, 1 error" >> ~/output/summary.txt
SCRIPT

bash /home/runner/process.sh
```

## Why this works

`>` redirects stdout, `2>` redirects stderr, `>>` appends instead of overwriting.
