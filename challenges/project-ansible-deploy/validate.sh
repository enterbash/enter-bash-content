#!/bin/bash

# Check role structure
for dir in tasks handlers defaults templates; do
  if [ ! -d ~/server-setup/roles/webserver/$dir ]; then
    echo "FAIL: roles/webserver/$dir/ directory missing"
    exit 1
  fi
done

if [ ! -f ~/server-setup/roles/webserver/tasks/main.yml ]; then
  echo "FAIL: roles/webserver/tasks/main.yml not found"
  exit 1
fi

if [ ! -f ~/server-setup/roles/webserver/handlers/main.yml ]; then
  echo "FAIL: roles/webserver/handlers/main.yml not found"
  exit 1
fi

if [ ! -f ~/server-setup/roles/webserver/defaults/main.yml ]; then
  echo "FAIL: roles/webserver/defaults/main.yml not found"
  exit 1
fi

if [ ! -f ~/server-setup/roles/webserver/templates/config.j2 ]; then
  echo "FAIL: roles/webserver/templates/config.j2 not found"
  exit 1
fi

# Check playbook exists
if [ ! -f ~/server-setup/playbook.yml ]; then
  echo "FAIL: ~/server-setup/playbook.yml not found"
  exit 1
fi

# Check playbook uses the role
if ! grep -q 'webserver' ~/server-setup/playbook.yml; then
  echo "FAIL: playbook.yml should use the webserver role"
  exit 1
fi

# Check playbook overrides app_env to staging
if ! grep -q 'staging' ~/server-setup/playbook.yml; then
  echo "FAIL: playbook.yml should override app_env to staging"
  exit 1
fi

# Run the playbook
cd ~/server-setup
if ! ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1; then
  echo "FAIL: Playbook has syntax errors — run ansible-playbook --syntax-check"
  exit 1
fi

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  echo "$RESULT" | tail -10
  exit 1
fi

# Check index.html
if [ ! -f /tmp/webserver/index.html ]; then
  echo "FAIL: /tmp/webserver/index.html not found"
  exit 1
fi
if ! grep -qi 'enter bash' /tmp/webserver/index.html; then
  echo "FAIL: index.html should contain 'Enter Bash'"
  exit 1
fi

# Check config.ini
if [ ! -f /tmp/webserver/config.ini ]; then
  echo "FAIL: /tmp/webserver/config.ini not found — use the template module"
  exit 1
fi
if ! grep -q 'port=8080' /tmp/webserver/config.ini; then
  echo "FAIL: config.ini should contain port=8080"
  exit 1
fi
if ! grep -q 'env=staging' /tmp/webserver/config.ini; then
  echo "FAIL: config.ini should contain env=staging (overridden in playbook vars)"
  exit 1
fi

# Check health.sh
if [ ! -x /tmp/webserver/health.sh ]; then
  echo "FAIL: /tmp/webserver/health.sh not found or not executable"
  exit 1
fi

# Check handler ran (restart marker)
if [ ! -f /tmp/webserver/restart.marker ]; then
  echo "FAIL: Handler did not run — use 'notify' in a task to trigger the restart handler"
  exit 1
fi

echo "PASS: Server setup automated with roles, templates, handlers, and variables"
exit 0
