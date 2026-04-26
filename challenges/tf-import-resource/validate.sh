#!/bin/bash
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1

# Check resource exists in state
terraform state list | grep -q 'local_file.app_config'

# Check resource block exists in config
grep -q 'resource "local_file" "app_config"' main.tf

# Plan should show no changes
PLAN=$(terraform plan -detailed-exitcode -input=false 2>&1) || EXIT_CODE=$?
if [ "${EXIT_CODE:-0}" -eq 0 ]; then
  echo "PASS: Resource imported successfully"
  exit 0
else
  echo "FAIL: terraform plan still shows changes"
  exit 1
fi
