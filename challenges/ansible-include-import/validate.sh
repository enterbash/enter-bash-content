#!/bin/bash
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -d /tmp/include-test ] || { echo "FAIL: /tmp/include-test not created"; exit 1; }
[ -d /tmp/include-test/logs ] || { echo "FAIL: logs directory not created"; exit 1; }
[ -f /tmp/include-test/app.conf ] || { echo "FAIL: app.conf not created"; exit 1; }
[ -f /tmp/include-test/logs/log.conf ] || { echo "FAIL: log.conf not created"; exit 1; }

echo "PASS: Include/import tasks working"
exit 0
