#!/bin/bash
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -f /tmp/system_info.txt ] || { echo "FAIL: /tmp/system_info.txt not created"; exit 1; }
grep -q "OS:" /tmp/system_info.txt || { echo "FAIL: OS line missing"; exit 1; }
grep -q "Hostname:" /tmp/system_info.txt || { echo "FAIL: Hostname line missing"; exit 1; }
grep -q "Architecture:" /tmp/system_info.txt || { echo "FAIL: Architecture line missing"; exit 1; }

# Make sure it's not using the broken variable names (would show literal {{ }})
if grep -q '{{' /tmp/system_info.txt; then
  echo "FAIL: Unresolved variables in output"
  exit 1
fi

echo "PASS: Facts used correctly"
exit 0
