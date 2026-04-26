#!/bin/bash
cd ~/ansible-project

ansible-playbook -i inventory.ini playbook.yml --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

grep -q "upstream backend" /tmp/blockinfile-test/nginx.conf || { echo "FAIL: upstream block not added"; exit 1; }
grep -q "server 127.0.0.1:8080" /tmp/blockinfile-test/nginx.conf || { echo "FAIL: backend server not in config"; exit 1; }
grep -q "listen 80" /tmp/blockinfile-test/nginx.conf || { echo "FAIL: server block not added"; exit 1; }
grep -q "proxy_pass" /tmp/blockinfile-test/nginx.conf || { echo "FAIL: proxy_pass not in config"; exit 1; }
grep -q "BEGIN MANAGED BLOCK" /tmp/blockinfile-test/nginx.conf || { echo "FAIL: marker lines missing"; exit 1; }

echo "PASS: Blockinfile working correctly"
exit 0
