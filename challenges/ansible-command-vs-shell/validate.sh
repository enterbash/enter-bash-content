#!/bin/bash
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -f /tmp/cmdshell/hostname.txt ] || { echo "FAIL: hostname.txt not created"; exit 1; }
[ -f /tmp/cmdshell/disk.txt ] || { echo "FAIL: disk.txt not created"; exit 1; }
[ -f /tmp/cmdshell/summary.txt ] || { echo "FAIL: summary.txt not created"; exit 1; }

HOSTNAME=$(hostname)
grep -q "$HOSTNAME" /tmp/cmdshell/hostname.txt || { echo "FAIL: hostname not in file"; exit 1; }
grep -q "user=" /tmp/cmdshell/summary.txt || { echo "FAIL: summary missing user info"; exit 1; }

echo "PASS: Command and shell modules used correctly"
exit 0
