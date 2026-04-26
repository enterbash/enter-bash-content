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

# Check sensitive markers
if ! grep -A5 'variable "db_password"' *.tf | grep -q 'sensitive.*=.*true'; then
  echo "FAIL: db_password variable should have sensitive = true"
  exit 1
fi
if ! grep -A5 'variable "api_key"' *.tf | grep -q 'sensitive.*=.*true'; then
  echo "FAIL: api_key variable should have sensitive = true"
  exit 1
fi

# Check outputs
if ! grep -q 'output "app_id"' *.tf; then
  echo "FAIL: Expected to find: output "app_id""
  exit 1
fi
if ! grep -q 'output "password_set"' *.tf; then
  echo "FAIL: Expected to find: output "password_set""
  exit 1
fi
if ! grep -A5 'output "password_set"' *.tf | grep -q 'sensitive.*=.*true'; then
  echo "FAIL: password_set output should have sensitive = true"
  exit 1
fi

# Check config resource
if ! grep -q 'local_file.*config' *.tf; then
  echo "FAIL: Expected to find: local_file.*config"
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
echo "PASS: Sensitive variables properly handled"
exit 0
