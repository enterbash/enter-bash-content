#!/bin/bash
cd ~/ansible-project

if ! ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1; then
  echo "FAIL: Playbook has syntax errors — run ansible-playbook --syntax-check to see details"
  exit 1
fi

set +e
RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
RC=$?
if [ $RC -ne 0 ] || ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  echo "$RESULT" | tail -20
  exit 1
fi

[ -f /tmp/copymod/db.conf ] || { echo "FAIL: db.conf not created"; exit 1; }
[ -f /tmp/copymod/app.conf ] || { echo "FAIL: app.conf not created"; exit 1; }
[ -f /tmp/copymod/readme.txt ] || { echo "FAIL: readme.txt not created"; exit 1; }

grep -q "host=localhost" /tmp/copymod/db.conf || { echo "FAIL: db.conf should have source content"; exit 1; }
grep -q "name=myapp" /tmp/copymod/app.conf || { echo "FAIL: app.conf content wrong"; exit 1; }

echo "PASS: Copy module working correctly"
exit 0
