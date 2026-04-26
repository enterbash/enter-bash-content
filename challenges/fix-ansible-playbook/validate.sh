#!/bin/bash
set -e
cd ~/ansible-project
ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1
if [ $? -eq 0 ]; then
  RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
  if echo "$RESULT" | grep -q "failed=0"; then
    echo "PASS: Playbook ran successfully"
    exit 0
  else
    echo "FAIL: Playbook had failures"
    exit 1
  fi
else
  echo "FAIL: Playbook has syntax errors"
  exit 1
fi
