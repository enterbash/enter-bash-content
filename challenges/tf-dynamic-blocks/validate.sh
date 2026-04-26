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

# Check dynamic block exists
grep -q 'dynamic "provisioner"' *.tf || grep -q 'dynamic "provisioner"' *.tf
if ! grep -q 'for_each' *.tf; then
  echo "FAIL: Expected to find: for_each"
  exit 1
fi
if ! grep -q 'content' *.tf; then
  echo "FAIL: Expected to find: content"
  exit 1
fi
if ! grep -q 'provisioner\.value' *.tf; then
  echo "FAIL: Expected to find: provisioner\.value"
  exit 1
fi

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Dynamic blocks properly configured"
exit 0
