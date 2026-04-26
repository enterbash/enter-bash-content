#!/bin/bash
set -e

# Check that /mnt/data is mounted
if ! mountpoint -q /mnt/data 2>/dev/null; then
  echo "FAIL: /mnt/data is not mounted"
  exit 1
fi

# Check that fstab has a valid entry for /mnt/data
if ! grep -qE '/opt/disk\.img\s+/mnt/data\s+ext4\s+.*loop' /etc/fstab; then
  echo "FAIL: /etc/fstab does not have correct entry for /mnt/data"
  exit 1
fi

# Check that the broken entry is removed
if grep -q '/dev/sdz99' /etc/fstab; then
  echo "FAIL: Broken /dev/sdz99 entry still in fstab"
  exit 1
fi

# Check mount -a works without errors
if ! sudo mount -a 2>/dev/null; then
  echo "FAIL: mount -a fails"
  exit 1
fi

echo "PASS: fstab is correct and filesystem is mounted"
exit 0
