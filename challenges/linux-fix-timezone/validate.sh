#!/bin/bash

# Check timezone is America/New_York
CURRENT_TZ=$(readlink -f /etc/localtime 2>/dev/null || true)
if ! echo "$CURRENT_TZ" | grep -q "America/New_York"; then
  # Also check /etc/timezone
  if [ -f /etc/timezone ]; then
    TZ_FILE=$(cat /etc/timezone)
    if [ "$TZ_FILE" != "America/New_York" ]; then
      echo "FAIL: Timezone is not America/New_York (got: $TZ_FILE)"
      exit 1
    fi
  else
    echo "FAIL: Timezone is not America/New_York"
    exit 1
  fi
fi

echo "PASS: Timezone is correctly set to America/New_York"
exit 0
