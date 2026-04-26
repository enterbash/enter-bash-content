#!/bin/bash

# Check en_US.UTF-8 is available
if ! locale -a 2>/dev/null | grep -qi 'en_US.utf-\?8'; then
  echo "FAIL: en_US.UTF-8 locale is not generated"
  exit 1
fi

# Check LANG is set correctly in /etc/default/locale
if ! grep -q 'LANG=en_US.UTF-8' /etc/default/locale 2>/dev/null; then
  echo "FAIL: /etc/default/locale does not have LANG=en_US.UTF-8"
  exit 1
fi

echo "PASS: Locale is correctly configured"
exit 0
