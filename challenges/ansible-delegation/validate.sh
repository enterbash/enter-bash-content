#!/bin/bash
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -f /tmp/delegation-test/app.conf ] || { echo "FAIL: app.conf not created"; exit 1; }
[ -f /tmp/delegation-test/deploy.log ] || { echo "FAIL: deploy.log not created"; exit 1; }
[ -f /tmp/delegation-test/monitoring.txt ] || { echo "FAIL: monitoring.txt not created"; exit 1; }

grep -q "version=1.0" /tmp/delegation-test/app.conf || { echo "FAIL: app.conf content wrong"; exit 1; }
grep -q "deployed version" /tmp/delegation-test/deploy.log || { echo "FAIL: deploy.log content wrong"; exit 1; }

echo "PASS: Delegation working correctly"
exit 0
