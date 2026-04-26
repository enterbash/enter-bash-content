#!/bin/bash
cd ~/ansible-project

if ! ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1; then
  echo "FAIL: Playbook has syntax errors — run ansible-playbook --syntax-check to see details"
  exit 1
fi

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -f /tmp/setfact-test/webapp/deploy_info.txt ] || { echo "FAIL: deploy_info.txt not created"; exit 1; }
grep -q "app_id=webapp-2.1" /tmp/setfact-test/webapp/deploy_info.txt || { echo "FAIL: app_id not set correctly"; exit 1; }
grep -q "deploy_time=" /tmp/setfact-test/webapp/deploy_info.txt || { echo "FAIL: deploy_time not set"; exit 1; }

# Make sure deploy_time has an actual value (not empty)
DEPLOY_TIME=$(grep "deploy_time=" /tmp/setfact-test/webapp/deploy_info.txt | cut -d= -f2)
[ -n "$DEPLOY_TIME" ] || { echo "FAIL: deploy_time is empty"; exit 1; }

echo "PASS: set_fact working correctly"
exit 0
