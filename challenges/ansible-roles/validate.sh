#!/bin/bash
set -e
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

# Check role structure exists
[ -d ~/ansible-project/roles/webapp/tasks ] || { echo "FAIL: roles/webapp/tasks/ missing"; exit 1; }
[ -f ~/ansible-project/roles/webapp/tasks/main.yml ] || { echo "FAIL: roles/webapp/tasks/main.yml missing"; exit 1; }
[ -f ~/ansible-project/roles/webapp/defaults/main.yml ] || { echo "FAIL: roles/webapp/defaults/main.yml missing"; exit 1; }

# Check results
[ -d /tmp/webapp ] || { echo "FAIL: /tmp/webapp not created"; exit 1; }
[ -f /tmp/webapp/config.txt ] || { echo "FAIL: /tmp/webapp/config.txt not created"; exit 1; }
grep -q "3000" /tmp/webapp/config.txt || { echo "FAIL: default port not in config"; exit 1; }

echo "PASS: Role working correctly"
exit 0
