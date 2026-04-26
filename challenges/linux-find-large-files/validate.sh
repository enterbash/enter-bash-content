#!/bin/bash
set -e

# Check that no files over 100MB exist under /home/runner
LARGE_FILES=$(find /home/runner -size +100M -type f 2>/dev/null)
if [ -n "$LARGE_FILES" ]; then
  echo "FAIL: Large files still exist:"
  echo "$LARGE_FILES"
  exit 1
fi

echo "PASS: No files over 100MB found"
exit 0
