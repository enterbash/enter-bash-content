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

# Check correct types
grep -A2 'variable "app_name"' *.tf | grep -q 'type.*=.*string'
grep -A2 'variable "port"' *.tf | grep -q 'type.*=.*number'
grep -A2 'variable "allowed_hosts"' *.tf | grep -q 'list(string)'
grep -A2 'variable "feature_flags"' *.tf | grep -q 'object'

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Type constraints are correct"
exit 0
