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

# Check override file exists
ls *override*.tf > /dev/null 2>&1

# Check override content
if ! grep -q 'development' *override*.tf; then
  echo "FAIL: Expected to find: development"
  exit 1
fi
if ! grep -q 'random_pet' *override*.tf; then
  echo "FAIL: Expected to find: random_pet"
  exit 1
fi
if ! grep -q 'length.*=.*3' *override*.tf; then
  echo "FAIL: Expected to find: length.*=.*3"
  exit 1
fi
if ! grep -q 'separator.*=.*"_"' *override*.tf; then
  echo "FAIL: Expected to find: separator.*=.*"_""
  exit 1
fi

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Override files properly configured"
exit 0
