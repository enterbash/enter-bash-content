#!/bin/bash
set -e

# Check GRUB_TIMEOUT is 5
if ! grep -q 'GRUB_TIMEOUT=5' /etc/default/grub; then
  echo "FAIL: GRUB_TIMEOUT should be 5"
  exit 1
fi

# Check GRUB_CMDLINE_LINUX_DEFAULT has quiet splash
if ! grep -q 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"' /etc/default/grub; then
  echo "FAIL: GRUB_CMDLINE_LINUX_DEFAULT should be \"quiet splash\""
  exit 1
fi

# Check GRUB_CMDLINE_LINUX is empty
if ! grep -q 'GRUB_CMDLINE_LINUX=""' /etc/default/grub; then
  echo "FAIL: GRUB_CMDLINE_LINUX should be empty"
  exit 1
fi

echo "PASS: GRUB configuration is correct"
exit 0
