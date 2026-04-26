#!/bin/bash
set -e

# Check results.txt exists and has stdout content
if [ ! -f /home/runner/output/results.txt ]; then
  echo "FAIL: results.txt does not exist"
  exit 1
fi

if ! grep -q 'Processing started\|Record.*OK\|Processing complete' /home/runner/output/results.txt; then
  echo "FAIL: results.txt does not contain expected output"
  exit 1
fi

# Check errors.log exists and has stderr content
if [ ! -f /home/runner/output/errors.log ]; then
  echo "FAIL: errors.log does not exist"
  exit 1
fi

if ! grep -q 'WARN\|ERROR' /home/runner/output/errors.log; then
  echo "FAIL: errors.log does not contain error messages"
  exit 1
fi

# Check summary.txt was appended (should have header AND run line)
if [ ! -f /home/runner/output/summary.txt ]; then
  echo "FAIL: summary.txt does not exist"
  exit 1
fi

if ! grep -q 'Processing Summary' /home/runner/output/summary.txt; then
  echo "FAIL: summary.txt is missing the original header (was overwritten instead of appended)"
  exit 1
fi

if ! grep -q 'Run completed' /home/runner/output/summary.txt; then
  echo "FAIL: summary.txt is missing the run summary line"
  exit 1
fi

echo "PASS: All redirections are correct"
exit 0
