#!/bin/bash
set -e

# Check sudoers file exists
if [ ! -f /etc/sudoers.d/developer ]; then
  echo "FAIL: /etc/sudoers.d/developer does not exist"
  exit 1
fi

# Check sudoers syntax is valid
if ! visudo -c > /dev/null 2>&1; then
  echo "FAIL: sudoers configuration has syntax errors"
  exit 1
fi

# Check developer can run systemctl
if ! sudo -l -U developer 2>/dev/null | grep -q 'systemctl'; then
  echo "FAIL: developer cannot run systemctl via sudo"
  exit 1
fi

# Check developer can run journalctl
if ! sudo -l -U developer 2>/dev/null | grep -q 'journalctl'; then
  echo "FAIL: developer cannot run journalctl via sudo"
  exit 1
fi

# Check NOPASSWD is set
if ! grep -q 'NOPASSWD' /etc/sudoers.d/developer; then
  echo "FAIL: NOPASSWD not configured"
  exit 1
fi

echo "PASS: sudo access correctly configured for developer"
exit 0
