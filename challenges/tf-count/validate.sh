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

PLAN_OUTPUT=$(terraform plan -input=false 2>&1)
if ! echo "$PLAN_OUTPUT" | grep -q 'local_file.config\[0\]'; then
  echo "FAIL: Plan does not show local_file.config[0] — check count and var.environments"
  exit 1
fi
if ! echo "$PLAN_OUTPUT" | grep -q 'local_file.config\[1\]'; then
  echo "FAIL: Plan does not show local_file.config[1] — check count and var.environments"
  exit 1
fi
if ! echo "$PLAN_OUTPUT" | grep -q 'local_file.config\[2\]'; then
  echo "FAIL: Plan does not show local_file.config[2] — check count and var.environments"
  exit 1
fi

echo "PASS: Count meta-argument properly configured"
exit 0
