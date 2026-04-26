#!/bin/bash
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
PLAN=$(terraform plan -detailed-exitcode -input=false 2>&1) || EXIT_CODE=$?
if [ "${EXIT_CODE:-0}" -eq 0 ]; then
  echo "PASS: No drift detected"
  exit 0
else
  echo "FAIL: Terraform plan shows changes"
  exit 1
fi
