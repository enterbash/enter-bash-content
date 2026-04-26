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

# Check locals block exists with required values
if ! grep -q 'locals' *.tf; then
  echo "FAIL: Expected to find: locals"
  exit 1
fi
if ! grep -q 'project_name' *.tf; then
  echo "FAIL: Expected to find: project_name"
  exit 1
fi
if ! grep -q 'environment' *.tf; then
  echo "FAIL: Expected to find: environment"
  exit 1
fi
if ! grep -q 'common_tags' *.tf; then
  echo "FAIL: Expected to find: common_tags"
  exit 1
fi

# Check locals are used in resources
if ! grep -q 'local\.' *.tf; then
  echo "FAIL: Expected to find: local\."
  exit 1
fi

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Local values properly defined and used"
exit 0
