#!/bin/bash

# Check backup script exists and is executable
if [ ! -x /home/runner/run-backup.sh ]; then
  echo "FAIL: /home/runner/run-backup.sh does not exist or is not executable"
  exit 1
fi

# Check script uses rsync
if ! grep -q 'rsync' /home/runner/run-backup.sh; then
  echo "FAIL: Backup script does not use rsync"
  exit 1
fi

# Check backup was run (files exist in backup dir)
if [ ! -f /home/runner/backup/src/app.js ]; then
  echo "FAIL: Backup missing src/app.js — run the backup script"
  exit 1
fi

if [ ! -f /home/runner/backup/package.json ]; then
  echo "FAIL: Backup missing package.json"
  exit 1
fi

# Check .git is excluded
if [ -d /home/runner/backup/.git ]; then
  echo "FAIL: .git/ directory should be excluded from backup"
  exit 1
fi

# Check node_modules is excluded
if [ -d /home/runner/backup/node_modules ]; then
  echo "FAIL: node_modules/ should be excluded from backup"
  exit 1
fi

echo "PASS: rsync backup is correctly configured and executed"
exit 0
