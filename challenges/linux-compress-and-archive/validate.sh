#!/bin/bash

# Check archive exists
if [ ! -f /home/runner/webapp-backup.tar.gz ]; then
  echo "FAIL: /home/runner/webapp-backup.tar.gz does not exist"
  exit 1
fi

# Check it's a valid gzip file
if ! file /home/runner/webapp-backup.tar.gz | grep -q 'gzip'; then
  echo "FAIL: File is not a valid gzip archive"
  exit 1
fi

# Check it contains expected files
CONTENTS=$(tar -tzf /home/runner/webapp-backup.tar.gz 2>/dev/null)
if ! echo "$CONTENTS" | grep -q 'index.html'; then
  echo "FAIL: Archive missing index.html"
  exit 1
fi

if ! echo "$CONTENTS" | grep -q 'app.js'; then
  echo "FAIL: Archive missing app.js"
  exit 1
fi

if ! echo "$CONTENTS" | grep -q 'settings.json'; then
  echo "FAIL: Archive missing settings.json"
  exit 1
fi

if ! echo "$CONTENTS" | grep -q 'README.md'; then
  echo "FAIL: Archive missing README.md"
  exit 1
fi

echo "PASS: Archive created with all expected files"
exit 0
