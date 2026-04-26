#!/bin/bash
cd ~/ansible-project

# Check that serial is defined in the playbook
grep -q "serial:" ~/ansible-project/playbook.yml || { echo "FAIL: serial not defined in playbook"; exit 1; }

if ! ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1; then
  echo "FAIL: Playbook has syntax errors — run ansible-playbook --syntax-check to see details"
  exit 1
fi

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -f /tmp/serial-deploy/app.conf ] || { echo "FAIL: app.conf not created"; exit 1; }
[ -f /tmp/serial-deploy/deployed.txt ] || { echo "FAIL: deployed.txt not created"; exit 1; }
grep -q "version=2.0" /tmp/serial-deploy/app.conf || { echo "FAIL: version wrong in app.conf"; exit 1; }

echo "PASS: Serial rolling update working"
exit 0
