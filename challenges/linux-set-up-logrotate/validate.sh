#!/bin/bash
set -e

# Check logrotate config exists
if [ ! -f /etc/logrotate.d/myapp ]; then
  echo "FAIL: /etc/logrotate.d/myapp does not exist"
  exit 1
fi

# Check config contains required directives
CONFIG=$(cat /etc/logrotate.d/myapp)

if ! echo "$CONFIG" | grep -q 'daily'; then
  echo "FAIL: Config missing 'daily' directive"
  exit 1
fi

if ! echo "$CONFIG" | grep -q 'rotate'; then
  echo "FAIL: Config missing 'rotate' directive"
  exit 1
fi

if ! echo "$CONFIG" | grep -q 'compress'; then
  echo "FAIL: Config missing 'compress' directive"
  exit 1
fi

if ! echo "$CONFIG" | grep -q '/var/log/myapp'; then
  echo "FAIL: Config does not reference /var/log/myapp"
  exit 1
fi

# Check that logrotate config is valid (dry run)
if ! sudo logrotate -d /etc/logrotate.d/myapp 2>&1 | grep -q 'considering log'; then
  echo "FAIL: Logrotate config has errors"
  exit 1
fi

echo "PASS: Logrotate is properly configured"
exit 0
