#!/bin/bash
cd ~/ansible-project

# Check inventory structure
ansible-inventory -i inventory.ini --list > /dev/null 2>&1 || { echo "FAIL: Inventory has parse errors"; exit 1; }

# Check groups exist
INVENTORY=$(ansible-inventory -i inventory.ini --list 2>&1)
echo "$INVENTORY" | grep -q "webservers" || { echo "FAIL: webservers group missing"; exit 1; }
echo "$INVENTORY" | grep -q "dbservers" || { echo "FAIL: dbservers group missing"; exit 1; }
echo "$INVENTORY" | grep -q "production" || { echo "FAIL: production group missing"; exit 1; }

if ! ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1; then
  echo "FAIL: Playbook has syntax errors — run ansible-playbook --syntax-check to see details"
  exit 1
fi

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -f /tmp/inventory-test/env_info.txt ] || { echo "FAIL: env_info.txt not created"; exit 1; }
grep -q "env=production" /tmp/inventory-test/env_info.txt || { echo "FAIL: env variable not set"; exit 1; }
grep -q "deploy_user=deploy" /tmp/inventory-test/env_info.txt || { echo "FAIL: deploy_user variable not set"; exit 1; }

echo "PASS: Inventory groups working correctly"
exit 0
