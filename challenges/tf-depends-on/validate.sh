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

# Check depends_on exists
if ! grep -q 'depends_on' *.tf; then
  echo "FAIL: Expected to find: depends_on"
  exit 1
fi
grep -A2 'depends_on' *.tf | grep -q 'null_resource\.create_dir'
grep -A2 'depends_on' *.tf | grep -q 'local_file\.app_config'

# Apply should succeed with correct ordering
terraform apply -auto-approve -input=false > /dev/null 2>&1

echo "PASS: Dependencies properly ordered"
exit 0
