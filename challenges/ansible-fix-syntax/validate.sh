#!/bin/bash
cd ~/ansible-project

# Check syntax
ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

# Run playbook and check for success
RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if echo "$RESULT" | grep -q "failed=0"; then
  echo "PASS: Playbook ran successfully"
else
  echo "FAIL: Playbook had failures"
  exit 1
fi

# Verify results
[ -d /tmp/myproject ] || { echo "FAIL: /tmp/myproject directory not created"; exit 1; }
[ -f /tmp/myproject/config.txt ] || { echo "FAIL: config.txt not created"; exit 1; }
[ -d /tmp/myproject/logs ] || { echo "FAIL: logs directory not created"; exit 1; }

echo "PASS: All checks passed"
exit 0
