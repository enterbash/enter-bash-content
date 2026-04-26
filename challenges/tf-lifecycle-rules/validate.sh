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

# Check lifecycle blocks exist
if ! grep -q 'lifecycle' *.tf; then
  echo "FAIL: Expected to find: lifecycle"
  exit 1
fi
if ! grep -q 'create_before_destroy.*=.*true' *.tf; then
  echo "FAIL: Expected to find: create_before_destroy.*=.*true"
  exit 1
fi
if ! grep -q 'ignore_changes' *.tf; then
  echo "FAIL: Expected to find: ignore_changes"
  exit 1
fi
if ! grep -q 'content' *.tf; then
  echo "FAIL: Expected to find: content"
  exit 1
fi
if ! grep -q 'prevent_destroy.*=.*true' *.tf; then
  echo "FAIL: Expected to find: prevent_destroy.*=.*true"
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
echo "PASS: Lifecycle rules properly configured"
exit 0
