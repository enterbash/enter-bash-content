#!/bin/bash
set -e
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

grep -q "^port=9090" /tmp/lineinfile-test/app.conf || { echo "FAIL: port not changed to 9090"; exit 1; }
grep -q "^debug=true" /tmp/lineinfile-test/app.conf || { echo "FAIL: debug not set to true"; exit 1; }
grep -q "^log_level=info" /tmp/lineinfile-test/app.conf || { echo "FAIL: log_level not set to info"; exit 1; }
grep -q "^environment=production" /tmp/lineinfile-test/app.conf || { echo "FAIL: environment line not added"; exit 1; }

echo "PASS: Lineinfile working correctly"
exit 0
