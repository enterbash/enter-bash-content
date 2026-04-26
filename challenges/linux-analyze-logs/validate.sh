#!/bin/bash
set -e

# Check report exists
if [ ! -f /home/runner/log-analysis.txt ]; then
  echo "FAIL: /home/runner/log-analysis.txt not found"
  exit 1
fi

# Check report is not empty
if [ ! -s /home/runner/log-analysis.txt ]; then
  echo "FAIL: Report is empty"
  exit 1
fi

# Check report mentions ERROR count
if ! grep -qi 'error' /home/runner/log-analysis.txt; then
  echo "FAIL: Report does not mention ERROR"
  exit 1
fi

# Check report contains some numbers (counts)
if ! grep -qE '[0-9]+' /home/runner/log-analysis.txt; then
  echo "FAIL: Report does not contain any counts"
  exit 1
fi

# Check report mentions the most common error (database connection)
if ! grep -qi 'database\|connection\|timeout' /home/runner/log-analysis.txt; then
  echo "FAIL: Report does not identify the most common error (database connection timeout)"
  exit 1
fi

echo "PASS: Log analysis report is complete"
exit 0
