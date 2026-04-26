#!/bin/bash
set -e
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1

# Check resource was renamed in state
terraform state list | grep -q 'random_pet.app_server'

# Check config was updated
grep -q 'resource "random_pet" "app_server"' main.tf
grep -q 'random_pet\.app_server' main.tf

# Plan should show no changes
PLAN=$(terraform plan -detailed-exitcode -input=false 2>&1) || EXIT_CODE=$?
if [ "${EXIT_CODE:-0}" -eq 0 ]; then
  echo "PASS: State management completed successfully"
  exit 0
else
  echo "FAIL: terraform plan still shows changes"
  exit 1
fi
