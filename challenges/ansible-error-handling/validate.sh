#!/bin/bash
set -e
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -f /tmp/errorhandling/error.log ] || { echo "FAIL: rescue did not run — error.log missing"; exit 1; }
[ -f /tmp/errorhandling/data.txt ] || { echo "FAIL: rescue did not create data.txt"; exit 1; }
[ -f /tmp/errorhandling/done.txt ] || { echo "FAIL: always did not run — done.txt missing"; exit 1; }
[ ! -f /tmp/errorhandling/should_not_exist.txt ] || { echo "FAIL: block continued after failure"; exit 1; }

grep -q "Error caught" /tmp/errorhandling/error.log || { echo "FAIL: error.log content wrong"; exit 1; }
grep -q "completed" /tmp/errorhandling/done.txt || { echo "FAIL: done.txt content wrong"; exit 1; }

echo "PASS: Error handling working correctly"
exit 0
