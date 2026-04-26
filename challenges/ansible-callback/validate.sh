#!/bin/bash
set -e
cd ~/ansible-project

# Check ansible.cfg has correct settings
grep -q "stdout_callback" ~/ansible-project/ansible.cfg || { echo "FAIL: stdout_callback not configured"; exit 1; }
grep -q "yaml" ~/ansible-project/ansible.cfg || { echo "FAIL: yaml callback not set"; exit 1; }

# Check for callbacks_enabled or callback_whitelist
(grep -q "callbacks_enabled" ~/ansible-project/ansible.cfg || grep -q "callback_whitelist" ~/ansible-project/ansible.cfg) || { echo "FAIL: callback_whitelist/callbacks_enabled not configured"; exit 1; }

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -f /tmp/callback-test/done.txt ] || { echo "FAIL: done.txt not created"; exit 1; }

echo "PASS: Callback plugins configured correctly"
exit 0
