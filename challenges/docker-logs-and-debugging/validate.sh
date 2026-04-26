#!/bin/bash

if [ ! -f ~/error-report.txt ]; then
  echo "FAIL: ~/error-report.txt not found"
  exit 1
fi

# Check first line contains app2
LINE1=$(head -1 ~/error-report.txt)
if ! echo "$LINE1" | grep -qi 'app2'; then
  echo "FAIL: first line should contain the failing container name (app2)"
  exit 1
fi

# Check second line contains the error
LINE2=$(sed -n '2p' ~/error-report.txt)
if ! echo "$LINE2" | grep -qi 'database\|connection\|refused\|error'; then
  echo "FAIL: second line should contain the error message"
  exit 1
fi

echo "PASS: error report is correct"
exit 0
