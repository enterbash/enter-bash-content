#!/bin/bash
cd ~/terraform-project
mkdir -p state

# Check backend config exists
if ! grep -q 'backend "local"' main.tf; then
  echo "FAIL: Expected to find: backend "local""
  exit 1
fi
if ! grep -q 'state/terraform.tfstate' main.tf; then
  echo "FAIL: Expected to find: state/terraform.tfstate"
  exit 1
fi

if ! terraform init -input=false > /dev/null 2>&1; then
  echo "FAIL: terraform init failed — check provider configuration"
  exit 1
fi
if ! terraform validate > /dev/null 2>&1; then
  echo "FAIL: terraform validate failed — check your HCL syntax"
  exit 1
fi

# Check state file is in the right place after apply
terraform plan -input=false > /dev/null 2>&1

echo "PASS: Backend properly configured"
exit 0
