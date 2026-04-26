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

if ! grep -q 'templatefile' *.tf; then
  echo "FAIL: Expected to find: templatefile"
  exit 1
fi
if ! grep -q 'config\.tftpl' *.tf; then
  echo "FAIL: Expected to find: config\.tftpl"
  exit 1
fi
if ! grep -q 'app_name' *.tf; then
  echo "FAIL: Expected to find: app_name"
  exit 1
fi
if ! grep -q 'environment' *.tf; then
  echo "FAIL: Expected to find: environment"
  exit 1
fi
if ! grep -q 'ports' *.tf; then
  echo "FAIL: Expected to find: ports"
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
echo "PASS: templatefile properly configured"
exit 0
