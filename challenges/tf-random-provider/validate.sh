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

if ! grep -q 'random_pet.*app_name' *.tf; then
  echo "FAIL: Expected to find: random_pet.*app_name"
  exit 1
fi
if ! grep -q 'random_integer.*port' *.tf; then
  echo "FAIL: Expected to find: random_integer.*port"
  exit 1
fi
if ! grep -q 'random_password.*db_password' *.tf; then
  echo "FAIL: Expected to find: random_password.*db_password"
  exit 1
fi
if ! grep -q 'random_uuid.*request_id' *.tf; then
  echo "FAIL: Expected to find: random_uuid.*request_id"
  exit 1
fi
if ! grep -q 'local_file.*config' *.tf; then
  echo "FAIL: Expected to find: local_file.*config"
  exit 1
fi

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Random provider resources properly configured"
exit 0
