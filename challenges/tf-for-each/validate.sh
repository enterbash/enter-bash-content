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

if ! grep -q 'for_each' *.tf; then
  echo "FAIL: Expected to find: for_each"
  exit 1
fi
if ! grep -q 'each\.key' *.tf; then
  echo "FAIL: Expected to find: each\.key"
  exit 1
fi
if ! grep -q 'each\.value' *.tf; then
  echo "FAIL: Expected to find: each\.value"
  exit 1
fi
if ! grep -q 'var\.services' *.tf; then
  echo "FAIL: Expected to find: var\.services"
  exit 1
fi

PLAN_OUTPUT=$(terraform plan -input=false 2>&1)
echo "$PLAN_OUTPUT" | grep -q 'local_file.service_config\["web"\]'
echo "$PLAN_OUTPUT" | grep -q 'local_file.service_config\["api"\]'
echo "$PLAN_OUTPUT" | grep -q 'local_file.service_config\["worker"\]'

echo "PASS: for_each properly configured"
exit 0
