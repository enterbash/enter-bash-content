#!/bin/bash
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

# Check that handlers section exists in playbook
grep -q "^  handlers:" ~/ansible-project/playbook.yml || grep -q "^handlers:" ~/ansible-project/playbook.yml || { echo "FAIL: No handlers section found"; exit 1; }

[ -f /tmp/myapp/app.conf ] || { echo "FAIL: app.conf not created"; exit 1; }
[ -f /tmp/myapp/logging.conf ] || { echo "FAIL: logging.conf not created"; exit 1; }
[ -f /tmp/myapp/restart.log ] || { echo "FAIL: restart handler did not run"; exit 1; }
[ -f /tmp/myapp/reload.log ] || { echo "FAIL: reload handler did not run"; exit 1; }

echo "PASS: Handlers working correctly"
exit 0
