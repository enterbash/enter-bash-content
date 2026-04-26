#!/bin/bash
cd ~/ansible-project
if ! ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1; then
  echo "FAIL: Playbook has syntax errors — run ansible-playbook --syntax-check to see details"
  exit 1
fi

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if echo "$RESULT" | grep -q "failed=0"; then
  echo "PASS: Playbook ran successfully"
  exit 0
else
  echo "FAIL: Playbook had failures"
  echo "$RESULT" | tail -10
  exit 1
fi
