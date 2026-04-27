#!/bin/bash

# Check module exists
if [ ! -f ~/infra/modules/app-config/main.tf ]; then
  echo "FAIL: ~/infra/modules/app-config/main.tf not found — create the module"
  exit 1
fi

if [ ! -f ~/infra/modules/app-config/variables.tf ]; then
  echo "FAIL: ~/infra/modules/app-config/variables.tf not found"
  exit 1
fi

if [ ! -f ~/infra/modules/app-config/outputs.tf ]; then
  echo "FAIL: ~/infra/modules/app-config/outputs.tf not found"
  exit 1
fi

# Check root main.tf exists and uses the module
if [ ! -f ~/infra/main.tf ]; then
  echo "FAIL: ~/infra/main.tf not found"
  exit 1
fi

if ! grep -q 'module' ~/infra/main.tf; then
  echo "FAIL: main.tf should use a module block"
  exit 1
fi

if ! grep -q 'terraform.workspace' ~/infra/main.tf; then
  echo "FAIL: main.tf should reference terraform.workspace for the environment"
  exit 1
fi

cd ~/infra

# Check terraform init works
if ! terraform init -input=false > /dev/null 2>&1; then
  echo "FAIL: terraform init failed — check module source path"
  exit 1
fi

# Check staging workspace exists
if ! terraform workspace list 2>/dev/null | grep -q 'staging'; then
  echo "FAIL: 'staging' workspace not found — run: terraform workspace new staging"
  exit 1
fi

# Check production workspace exists
if ! terraform workspace list 2>/dev/null | grep -q 'production'; then
  echo "FAIL: 'production' workspace not found — run: terraform workspace new production"
  exit 1
fi

# Check staging was applied
terraform workspace select staging > /dev/null 2>&1
EXIT_CODE=0
terraform plan -detailed-exitcode -input=false > /dev/null 2>&1 || EXIT_CODE=$?
if [ "$EXIT_CODE" -eq 2 ]; then
  echo "FAIL: staging workspace has unapplied changes — run: terraform apply -auto-approve"
  exit 1
fi

# Check production was applied
terraform workspace select production > /dev/null 2>&1
EXIT_CODE=0
terraform plan -detailed-exitcode -input=false > /dev/null 2>&1 || EXIT_CODE=$?
if [ "$EXIT_CODE" -eq 2 ]; then
  echo "FAIL: production workspace has unapplied changes — run: terraform apply -auto-approve"
  exit 1
fi

# Check module has outputs
if ! grep -q 'output' ~/infra/modules/app-config/outputs.tf; then
  echo "FAIL: modules/app-config/outputs.tf should define at least one output"
  exit 1
fi

echo "PASS: Multi-environment infrastructure deployed with modules and workspaces"
exit 0
