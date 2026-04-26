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

[ -f /tmp/app/config.ini ] || { echo "FAIL: /tmp/app/config.ini not created"; exit 1; }

grep -q "name=myapp" /tmp/app/config.ini || { echo "FAIL: app_name variable not used"; exit 1; }
grep -q "port=8080" /tmp/app/config.ini || { echo "FAIL: app_port variable not used"; exit 1; }

echo "PASS: All variable checks passed"
exit 0
