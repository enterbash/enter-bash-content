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
EXIT_CODE=0
terraform plan -input=false > /dev/null 2>&1 || EXIT_CODE=$?
if [ "$EXIT_CODE" -eq 2 ]; then
  echo "FAIL: terraform plan shows pending changes — your config may be incomplete"
  exit 1
elif [ "$EXIT_CODE" -ne 0 ]; then
  echo "FAIL: terraform plan encountered an error"
  exit 1
fi

echo "PASS: Backend properly configured"
exit 0
