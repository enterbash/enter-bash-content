#!/bin/bash
set -e

# Check rogue processes are killed
if pgrep -f 'mem_leak' > /dev/null 2>&1; then
  echo "FAIL: mem_leak process is still running"
  exit 1
fi

if pgrep -f 'cpu_hog2' > /dev/null 2>&1; then
  echo "FAIL: cpu_hog2 process is still running"
  exit 1
fi

# Check system report exists
if [ ! -f /home/runner/system-report.txt ]; then
  echo "FAIL: /home/runner/system-report.txt not found"
  exit 1
fi

# Check report has content
if [ ! -s /home/runner/system-report.txt ]; then
  echo "FAIL: System report is empty"
  exit 1
fi

# Check report contains memory info
if ! grep -qiE 'mem|swap|free|total|used|available' /home/runner/system-report.txt; then
  echo "FAIL: Report missing memory information"
  exit 1
fi

echo "PASS: Rogue processes killed and system report created"
exit 0
