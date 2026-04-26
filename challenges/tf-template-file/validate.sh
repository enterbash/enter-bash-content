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

terraform plan -input=false > /dev/null 2>&1
echo "PASS: templatefile properly configured"
exit 0
