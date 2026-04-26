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

# Check that variables are defined
if ! grep -q 'variable "project_name"' *.tf; then
  echo "FAIL: Expected to find: variable "project_name""
  exit 1
fi
if ! grep -q 'variable "environment"' *.tf; then
  echo "FAIL: Expected to find: variable "environment""
  exit 1
fi
if ! grep -q 'variable "file_count"' *.tf; then
  echo "FAIL: Expected to find: variable "file_count""
  exit 1
fi

# Check that variables are used
if ! grep -q 'var\.project_name' *.tf; then
  echo "FAIL: Expected to find: var\.project_name"
  exit 1
fi
if ! grep -q 'var\.environment' *.tf; then
  echo "FAIL: Expected to find: var\.environment"
  exit 1
fi
if ! grep -q 'var\.file_count' *.tf; then
  echo "FAIL: Expected to find: var\.file_count"
  exit 1
fi

# Check defaults
if ! grep -A5 'variable "project_name"' *.tf | grep -q 'default.*"my-app"'; then
  echo "FAIL: project_name variable should have default = \"my-app\""
  exit 1
fi
if ! grep -A5 'variable "environment"' *.tf | grep -q 'default.*"staging"'; then
  echo "FAIL: environment variable should have default = \"staging\""
  exit 1
fi
if ! grep -A5 'variable "file_count"' *.tf | grep -q 'default.*3'; then
  echo "FAIL: file_count variable should have default = 3"
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
echo "PASS: Variables properly defined and used"
exit 0
