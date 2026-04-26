#!/bin/bash
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

which curl > /dev/null 2>&1 || { echo "FAIL: curl not installed"; exit 1; }
which jq > /dev/null 2>&1 || { echo "FAIL: jq not installed"; exit 1; }
which tree > /dev/null 2>&1 || { echo "FAIL: tree not installed"; exit 1; }
[ -f /tmp/packages_installed.txt ] || { echo "FAIL: verification file not created"; exit 1; }

echo "PASS: All packages installed"
exit 0
