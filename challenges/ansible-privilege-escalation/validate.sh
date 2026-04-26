#!/bin/bash
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -f /tmp/priv-test/root_user.txt ] || { echo "FAIL: root_user.txt not created"; exit 1; }
[ -f /tmp/priv-test/deploy_user.txt ] || { echo "FAIL: deploy_user.txt not created"; exit 1; }
[ -f /tmp/priv-test/status.txt ] || { echo "FAIL: status.txt not created"; exit 1; }

grep -q "root" /tmp/priv-test/root_user.txt || { echo "FAIL: root task not running as root"; exit 1; }
grep -q "deploy" /tmp/priv-test/deploy_user.txt || { echo "FAIL: deploy task not running as deploy"; exit 1; }

# Check playbook uses become, not sudo
grep -q "sudo:" ~/ansible-project/playbook.yml && { echo "FAIL: Still using deprecated 'sudo:' — use 'become:'"; exit 1; }
grep -q "become:" ~/ansible-project/playbook.yml || { echo "FAIL: 'become:' not found in playbook"; exit 1; }

echo "PASS: Privilege escalation working correctly"
exit 0
