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

if ! grep -q 'try(' *.tf; then
  echo "FAIL: Expected to find: try("
  exit 1
fi
if ! grep -q 'can(' *.tf; then
  echo "FAIL: Expected to find: can("
  exit 1
fi
if ! grep -q 'default-app' *.tf; then
  echo "FAIL: Expected to find: default-app"
  exit 1
fi
if ! grep -q '8080' *.tf; then
  echo "FAIL: Expected to find: 8080"
  exit 1
fi
if ! grep -q 'localhost' *.tf; then
  echo "FAIL: Expected to find: localhost"
  exit 1
fi

EXIT_CODE=0
terraform plan -input=false > /dev/null 2>&1 || EXIT_CODE=$?
if [ "$EXIT_CODE" -eq 2 ]; then
  echo "FAIL: terraform plan shows pending changes — your config may be incomplete"
  exit 1
elif [ "$EXIT_CODE" -ne 0 ]; then
  echo "FAIL: terraform plan encountered an error"
  exit 1
fi
echo "PASS: try and can functions properly used"
exit 0
