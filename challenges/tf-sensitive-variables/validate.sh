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
grep -A5 'variable "db_password"' *.tf | grep -q 'sensitive.*=.*true'
grep -A5 'variable "api_key"' *.tf | grep -q 'sensitive.*=.*true'

# Check outputs
if ! grep -q 'output "app_id"' *.tf; then
  echo "FAIL: Expected to find: output "app_id""
  exit 1
fi
if ! grep -q 'output "password_set"' *.tf; then
  echo "FAIL: Expected to find: output "password_set""
  exit 1
fi
grep -A5 'output "password_set"' *.tf | grep -q 'sensitive.*=.*true'

# Check config resource
if ! grep -q 'local_file.*config' *.tf; then
  echo "FAIL: Expected to find: local_file.*config"
  exit 1
fi

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Sensitive variables properly handled"
exit 0
