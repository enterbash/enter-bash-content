#!/bin/bash
set -e

# Check that apt update succeeds
if ! sudo apt update > /dev/null 2>&1; then
  echo "FAIL: apt update still fails"
  exit 1
fi

# Check that broken PPA is removed
if [ -f /etc/apt/sources.list.d/broken-ppa.list ]; then
  if grep -q 'broken.invalid' /etc/apt/sources.list.d/broken-ppa.list; then
    echo "FAIL: Broken PPA file still exists"
    exit 1
  fi
fi

# Check sources.list has valid entries
if grep -q 'nonexistent.invalid\|also-broken.invalid' /etc/apt/sources.list; then
  echo "FAIL: Invalid sources still in sources.list"
  exit 1
fi

echo "PASS: APT sources are working"
exit 0
