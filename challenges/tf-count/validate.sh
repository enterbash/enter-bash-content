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

# Check count is used
if ! grep -q 'count' *.tf; then
  echo "FAIL: Expected to find: count"
  exit 1
fi
if ! grep -q 'count\.index' *.tf; then
  echo "FAIL: Expected to find: count\.index"
  exit 1
fi
if ! grep -q 'length(var\.environments)' *.tf; then
  echo "FAIL: Expected to find: length(var\.environments)"
  exit 1
fi

terraform plan -input=false > /dev/null 2>&1
PLAN_OUTPUT=$(terraform plan -input=false 2>&1)
echo "$PLAN_OUTPUT" | grep -q 'local_file.config\[0\]'
echo "$PLAN_OUTPUT" | grep -q 'local_file.config\[1\]'
echo "$PLAN_OUTPUT" | grep -q 'local_file.config\[2\]'

echo "PASS: Count meta-argument properly configured"
exit 0
