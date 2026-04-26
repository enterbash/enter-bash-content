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

# Check module call in root
if ! grep -q 'module "app_config"' main.tf; then
  echo "FAIL: Expected to find: module "app_config""
  exit 1
fi
if ! grep -q 'source.*modules/config' main.tf; then
  echo "FAIL: Expected to find: source.*modules/config"
  exit 1
fi
if ! grep -q 'app_name' main.tf; then
  echo "FAIL: Expected to find: app_name"
  exit 1
fi
if ! grep -q 'environment' main.tf; then
  echo "FAIL: Expected to find: environment"
  exit 1
fi

# Check module definition
if ! grep -q 'variable "app_name"' modules/config/main.tf; then
  echo "FAIL: Expected to find: variable "app_name""
  exit 1
fi
if ! grep -q 'variable "environment"' modules/config/main.tf; then
  echo "FAIL: Expected to find: variable "environment""
  exit 1
fi
if ! grep -q 'resource "local_file"' modules/config/main.tf; then
  echo "FAIL: Expected to find: resource "local_file""
  exit 1
fi
if ! grep -q 'output "config_path"' modules/config/main.tf; then
  echo "FAIL: Expected to find: output "config_path""
  exit 1
fi

# Check root output
if ! grep -q 'output "config_file"' main.tf; then
  echo "FAIL: Expected to find: output "config_file""
  exit 1
fi
if ! grep -q 'module\.app_config' main.tf; then
  echo "FAIL: Expected to find: module\.app_config"
  exit 1
fi

EXIT_CODE=0
terraform plan -input=false > /dev/null 2>&1 || EXIT_CODE=$?
if [ "$EXIT_CODE" -eq 2 ]; then
  echo "FAIL: terraform plan shows pending changes — your config may be incomplete"
  exit 1
elif [ "$EXIT_CODE" -ne 0 ]; then
  echo "FAIL: terraform plan encountered an error"
  exit 1
fi
echo "PASS: Module properly defined and called"
exit 0
