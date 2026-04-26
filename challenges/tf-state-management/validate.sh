#!/bin/bash
cd ~/terraform-project
if ! terraform init -input=false > /dev/null 2>&1; then
  echo "FAIL: terraform init failed — check provider configuration"
  exit 1
fi

# Check resource was renamed in state
if ! terraform state list 2>/dev/null | grep -q 'random_pet.app_server'; then
  echo "FAIL: random_pet.app_server not found in state — run: terraform state mv random_pet.server random_pet.app_server"
  exit 1
fi

# Check config was updated
if ! grep -q 'resource "random_pet" "app_server"' main.tf; then
  echo "FAIL: main.tf still has 'random_pet \"server\"' — rename the resource block to 'app_server'"
  exit 1
fi

if ! grep -q 'random_pet\.app_server' main.tf; then
  echo "FAIL: main.tf still references random_pet.server — update all references to random_pet.app_server"
  exit 1
fi

# Plan should show no changes (exit code 0 = no changes, 2 = changes pending)
EXIT_CODE=0
terraform plan -detailed-exitcode -input=false > /dev/null 2>&1 || EXIT_CODE=$?
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "PASS: State management operations completed successfully"
  exit 0
elif [ "$EXIT_CODE" -eq 2 ]; then
  echo "FAIL: terraform plan shows pending changes — state and config are out of sync"
  exit 1
else
  echo "FAIL: terraform plan encountered an error"
  exit 1
fi
