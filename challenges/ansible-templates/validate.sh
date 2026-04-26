#!/bin/bash
set -e
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -f /tmp/webapp/app.conf ] || { echo "FAIL: /tmp/webapp/app.conf not created"; exit 1; }

grep -q "name = webapp" /tmp/webapp/app.conf || { echo "FAIL: app_name not rendered"; exit 1; }
grep -q "port = 8080" /tmp/webapp/app.conf || { echo "FAIL: app_port not rendered"; exit 1; }
grep -q "ssl_enabled = true" /tmp/webapp/app.conf || { echo "FAIL: SSL conditional not rendered"; exit 1; }

# Ensure no raw Jinja2 syntax remains
if grep -q '{%' /tmp/webapp/app.conf || grep -q '{{' /tmp/webapp/app.conf; then
  echo "FAIL: Unrendered Jinja2 syntax in output"
  exit 1
fi

echo "PASS: Templates rendered correctly"
exit 0
