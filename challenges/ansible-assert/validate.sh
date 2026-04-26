#!/bin/bash
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -f /tmp/assert_results.txt ] || { echo "FAIL: assert_results.txt not created"; exit 1; }
grep -q "port=8080 VALID" /tmp/assert_results.txt || { echo "FAIL: port validation missing"; exit 1; }
grep -q "name=webapp VALID" /tmp/assert_results.txt || { echo "FAIL: name validation missing"; exit 1; }

echo "PASS: Assert module working correctly"
exit 0
