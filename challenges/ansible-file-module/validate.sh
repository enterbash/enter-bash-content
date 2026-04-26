#!/bin/bash
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -d /tmp/filemod-app ] || { echo "FAIL: /tmp/filemod-app directory not created"; exit 1; }
[ -d /tmp/filemod-app/data ] || { echo "FAIL: data directory not created"; exit 1; }
[ -f /tmp/filemod-app/app.log ] || { echo "FAIL: app.log not created"; exit 1; }
[ -L /tmp/filemod-data-link ] || { echo "FAIL: symlink not created"; exit 1; }

# Check permissions
PERMS=$(stat -c %a /tmp/filemod-app)
[ "$PERMS" = "755" ] || { echo "FAIL: /tmp/filemod-app permissions wrong: $PERMS"; exit 1; }

echo "PASS: File module working correctly"
exit 0
