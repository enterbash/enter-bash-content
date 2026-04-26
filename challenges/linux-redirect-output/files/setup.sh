#!/bin/bash
set -e

mkdir -p /home/runner/output

# Create an initial summary file
echo "=== Processing Summary ===" > /home/runner/output/summary.txt

# Create a broken processing script
cat > /home/runner/process.sh <<'SCRIPT'
#!/bin/bash
# Data processing script — redirections are broken!

# This should write results to ~/output/results.txt (stdout)
# But it's writing to stderr instead
echo "Processing started at $(date)" >&2
echo "Record 1: OK" >&2
echo "Record 2: OK" >&2
echo "Record 3: OK" >&2
echo "Processing complete: 3 records" >&2

# This should write errors to ~/output/errors.log (stderr)
# But it's writing to stdout instead
echo "WARN: Record 4 had missing fields" >&1
echo "ERROR: Record 5 failed validation" >&1

# This should APPEND a summary line to ~/output/summary.txt
# But it's overwriting instead of appending
echo "Run completed: $(date) — 3 success, 1 warn, 1 error" > /home/runner/output/summary.txt
SCRIPT

chmod +x /home/runner/process.sh
chown -R runner:runner /home/runner/output /home/runner/process.sh
