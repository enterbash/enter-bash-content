#!/bin/bash
cd ~/terraform-project
if ! terraform init -input=false > /dev/null 2>&1; then
  echo "FAIL: terraform init failed — check provider configuration"
  exit 1
fi

# Check terraform.workspace is used in config
if ! grep -q 'terraform\.workspace' main.tf; then
  echo "FAIL: Expected to find: terraform\.workspace"
  exit 1
fi

# Check staging workspace exists
if ! terraform workspace list 2>/dev/null | grep -q 'staging'; then
  echo "FAIL: 'staging' workspace not found — run: terraform workspace new staging"
  exit 1
fi

if ! terraform validate > /dev/null 2>&1; then
  echo "FAIL: terraform validate failed — check your HCL syntax"
  exit 1
fi
echo "PASS: Workspaces properly configured"
exit 0
