#!/bin/bash
cd ~/terraform-project
if ! terraform init -input=false > /dev/null 2>&1; then
  echo "FAIL: terraform init failed — check provider configuration"
  exit 1
fi

# Check resource exists in state
if ! terraform state list 2>/dev/null | grep -q 'local_file.app_config'; then
  echo "FAIL: local_file.app_config not found in state — run: terraform import local_file.app_config ~/terraform-project/app-config.txt"
  exit 1
fi

# Check resource block exists in config
if ! grep -q 'resource "local_file" "app_config"' main.tf; then
  echo "FAIL: Expected to find: resource "local_file" "app_config""
  exit 1
fi

# Plan should show no changes
PLAN=$(terraform plan -detailed-exitcode -input=false 2>&1) || EXIT_CODE=$?
if [ "${EXIT_CODE:-0}" -eq 0 ]; then
  echo "PASS: Resource imported successfully"
  exit 0
else
  echo "FAIL: terraform plan still shows changes"
  exit 1
fi
