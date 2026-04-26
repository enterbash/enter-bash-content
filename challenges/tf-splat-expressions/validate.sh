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

if ! grep -q '\[\*\]' *.tf; then
  echo "FAIL: Expected to find: \[\*\]"
  exit 1
fi
if ! grep -q 'output "all_pet_names"' *.tf; then
  echo "FAIL: Expected to find: output "all_pet_names""
  exit 1
fi
if ! grep -q 'output "all_file_paths"' *.tf; then
  echo "FAIL: Expected to find: output "all_file_paths""
  exit 1
fi
if ! grep -q 'local_file.*summary' *.tf; then
  echo "FAIL: Expected to find: local_file.*summary"
  exit 1
fi
if ! grep -q 'join' *.tf; then
  echo "FAIL: Expected to find: join"
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
echo "PASS: Splat expressions properly used"
exit 0
