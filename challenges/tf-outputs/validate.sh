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

# Check outputs exist
if ! grep -q 'output "pet_name"' *.tf; then
  echo "FAIL: Expected to find: output "pet_name""
  exit 1
fi
if ! grep -q 'output "config_path"' *.tf; then
  echo "FAIL: Expected to find: output "config_path""
  exit 1
fi
if ! grep -q 'output "random_number"' *.tf; then
  echo "FAIL: Expected to find: output "random_number""
  exit 1
fi

# Check output values reference correct resources
grep -A3 'output "pet_name"' *.tf | grep -q 'random_pet\.server\.id'
grep -A3 'output "config_path"' *.tf | grep -q 'local_file\.config\.filename'
grep -A3 'output "random_number"' *.tf | grep -q 'random_integer\.priority\.result'

# Check description on random_number
grep -A5 'output "random_number"' *.tf | grep -q 'description'

EXIT_CODE=0
terraform plan -input=false > /dev/null 2>&1 || EXIT_CODE=$?
if [ "$EXIT_CODE" -eq 2 ]; then
  echo "FAIL: terraform plan shows pending changes — your config may be incomplete"
  exit 1
elif [ "$EXIT_CODE" -ne 0 ]; then
  echo "FAIL: terraform plan encountered an error"
  exit 1
fi
echo "PASS: All outputs properly defined"
exit 0
