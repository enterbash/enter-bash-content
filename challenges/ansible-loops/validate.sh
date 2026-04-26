#!/bin/bash
set -e
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

for app in frontend backend worker; do
  [ -d "/tmp/apps/$app" ] || { echo "FAIL: /tmp/apps/$app not created"; exit 1; }
  [ -f "/tmp/apps/$app/config.txt" ] || { echo "FAIL: /tmp/apps/$app/config.txt not created"; exit 1; }
  [ -d "/tmp/apps/$app/logs" ] || { echo "FAIL: /tmp/apps/$app/logs not created"; exit 1; }
done

grep -q "port=3000" /tmp/apps/frontend/config.txt || { echo "FAIL: frontend port wrong"; exit 1; }
grep -q "port=8080" /tmp/apps/backend/config.txt || { echo "FAIL: backend port wrong"; exit 1; }

echo "PASS: All loops working correctly"
exit 0
