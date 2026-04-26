#!/bin/bash
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -f /tmp/lookup-test/results.txt ] || { echo "FAIL: results.txt not created"; exit 1; }
grep -q "greeting=Hello from lookup" /tmp/lookup-test/results.txt || { echo "FAIL: file lookup not working"; exit 1; }
grep -q "home=/" /tmp/lookup-test/results.txt || { echo "FAIL: env lookup not working"; exit 1; }

echo "PASS: Lookup plugins working correctly"
exit 0
