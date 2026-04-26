# Solution: Fix Shell Redirections

## What the validator checks

- **Check results.txt exists and has stdout content**: results.txt does not exist
- results.txt does not contain expected output
- **Check errors.log exists and has stderr content**: errors.log does not exist
- errors.log does not contain error messages
- **Check summary.txt was appended (should have header AND run line)**: summary.txt does not exist
- summary.txt is missing the original header (was overwritten instead of appended)
- summary.txt is missing the run summary line

## Solution

```bash
# Fix the redirections in process.sh:
# > redirects stdout, 2> redirects stderr, >> appends

cat > /home/runner/process.sh << 'SCRIPT'
#!/bin/bash
echo "Processing started" > ~/output/results.txt
echo "Record 1: OK" >> ~/output/results.txt
echo "Record 2: OK" >> ~/output/results.txt
echo "WARN: missing field" 2>> ~/output/errors.log
echo "Run completed" >> ~/output/summary.txt
SCRIPT

bash /home/runner/process.sh
```

Key: `>` overwrites, `>>` appends, `2>` redirects stderr.
