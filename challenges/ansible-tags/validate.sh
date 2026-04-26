#!/bin/bash
set -e
cd ~/ansible-project

# Check that tags exist
TAGS=$(ansible-playbook -i inventory.ini playbook.yml --list-tags 2>&1)
echo "$TAGS" | grep -q "setup" || { echo "FAIL: 'setup' tag not found"; exit 1; }
echo "$TAGS" | grep -q "config" || { echo "FAIL: 'config' tag not found"; exit 1; }

# Run only setup tags
RESULT=$(ansible-playbook -i inventory.ini playbook.yml --tags setup 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Setup tags failed"
  exit 1
fi

[ -d /tmp/tagapp ] || { echo "FAIL: /tmp/tagapp not created by setup tag"; exit 1; }

# Run full playbook
RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Full playbook had failures"
  exit 1
fi

[ -f /tmp/tagapp/app.conf ] || { echo "FAIL: app.conf not created"; exit 1; }
[ -f /tmp/tagapp/logs/log.conf ] || { echo "FAIL: log.conf not created"; exit 1; }

echo "PASS: Tags working correctly"
exit 0
