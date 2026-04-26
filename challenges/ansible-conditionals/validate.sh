#!/bin/bash
cd ~/ansible-project

if ! ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1; then
  echo "FAIL: Playbook has syntax errors — run ansible-playbook --syntax-check to see details"
  exit 1
fi

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -f /tmp/prod_config.txt ] || { echo "FAIL: prod_config.txt not created"; exit 1; }
[ -f /tmp/logging.conf ] || { echo "FAIL: logging.conf not created"; exit 1; }
[ -f /tmp/port_info.txt ] || { echo "FAIL: port_info.txt not created"; exit 1; }

echo "PASS: All conditionals working"
exit 0
