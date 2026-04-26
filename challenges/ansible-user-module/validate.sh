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

id deploy > /dev/null 2>&1 || { echo "FAIL: deploy user not created"; exit 1; }
id appuser > /dev/null 2>&1 || { echo "FAIL: appuser user not created"; exit 1; }

# Check deploy user's shell
SHELL=$(getent passwd deploy | cut -d: -f7)
[ "$SHELL" = "/bin/bash" ] || { echo "FAIL: deploy shell is $SHELL, expected /bin/bash"; exit 1; }

# Check appuser is in deploy group
groups appuser | grep -q deploy || { echo "FAIL: appuser not in deploy group"; exit 1; }

[ -f /tmp/users_created.txt ] || { echo "FAIL: users_created.txt not created"; exit 1; }

echo "PASS: User management working"
exit 0
