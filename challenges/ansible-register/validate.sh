#!/bin/bash
set -e
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -f /tmp/register_output.txt ] || { echo "FAIL: register_output.txt not created"; exit 1; }

# Should contain actual values, not raw dict/variable references
if grep -q "{'changed'" /tmp/register_output.txt; then
  echo "FAIL: Raw register dict in output — use .stdout"
  exit 1
fi

HOSTNAME=$(hostname)
grep -q "hostname=$HOSTNAME" /tmp/register_output.txt || { echo "FAIL: hostname not captured correctly"; exit 1; }

echo "PASS: Register and debug working"
exit 0
