#!/bin/bash
cd ~/terraform-project
if ! terraform init -input=false > /dev/null 2>&1; then
  echo "FAIL: terraform init failed — check provider configuration"
  exit 1
fi
if ! terraform validate > /dev/null 2>&1; then
  echo "FAIL: terraform validate failed — check your HCL syntax"
  exit 1
fi

# Check conditional expressions exist
if ! grep -q '?' *.tf; then
  echo "FAIL: Expected to find: ?"
  exit 1
fi
if ! grep -q 'var\.environment' *.tf; then
  echo "FAIL: Expected to find: var\.environment"
  exit 1
fi
if ! grep -q 'var\.enable_debug' *.tf; then
  echo "FAIL: Expected to find: var\.enable_debug"
  exit 1
fi
if ! grep -q 'count' *.tf; then
  echo "FAIL: Expected to find: count"
  exit 1
fi

# Check config resource
grep -A5 'resource "local_file" "config"' *.tf | grep -q 'production'

# Check debug_log resource with count
grep -A5 'resource "local_file" "debug_log"' *.tf | grep -q 'count'

# Plan with defaults (production, debug=false) should work
EXIT_CODE=0
terraform plan -input=false > /dev/null 2>&1 || EXIT_CODE=$?
if [ "$EXIT_CODE" -eq 2 ]; then
  echo "FAIL: terraform plan shows pending changes — your config may be incomplete"
  exit 1
elif [ "$EXIT_CODE" -ne 0 ]; then
  echo "FAIL: terraform plan encountered an error"
  exit 1
fi

# Plan with non-production should also work
terraform plan -input=false -var="environment=staging" -var="enable_debug=true" > /dev/null 2>&1

echo "PASS: Conditional expressions properly configured"
exit 0
