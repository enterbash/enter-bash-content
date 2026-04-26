#!/bin/bash

# Check that backup script is executable
if [ ! -x /home/runner/backup.sh ]; then
  echo "FAIL: backup.sh is not executable"
  exit 1
fi

# Check that crontab has a valid entry for the backup
CRONTAB=$(crontab -l 2>/dev/null || true)
if ! echo "$CRONTAB" | grep -qE '^0 2 \* \* \* .*/backup\.sh'; then
  echo "FAIL: Crontab does not have correct daily 2AM backup entry"
  exit 1
fi

# Check that backup script runs successfully
if ! bash /home/runner/backup.sh > /dev/null 2>&1; then
  echo "FAIL: backup.sh does not run successfully"
  exit 1
fi

# Check that backup file was created
if [ ! -f /home/runner/backups/backup.tar.gz ]; then
  echo "FAIL: Backup file was not created"
  exit 1
fi

echo "PASS: Crontab is correct and backup script works"
exit 0
