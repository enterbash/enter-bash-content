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

[ -f /tmp/myservice-conf/service.conf ] || { echo "FAIL: service.conf not created"; exit 1; }
[ -f /tmp/myservice.pid ] || { echo "FAIL: service not started (no PID file)"; exit 1; }
[ -f /tmp/myservice-conf/status.txt ] || { echo "FAIL: status.txt not created"; exit 1; }
grep -q "running" /tmp/myservice-conf/status.txt || { echo "FAIL: service not reporting running"; exit 1; }

echo "PASS: Service management working"
exit 0
