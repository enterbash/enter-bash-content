#!/bin/bash
cd ~/terraform-project
if ! terraform init -input=false > /dev/null 2>&1; then
  echo "FAIL: terraform init failed — check provider configuration"
  exit 1
fi

# Check moved blocks exist
if ! grep -q 'moved' *.tf; then
  echo "FAIL: Expected to find: moved"
  exit 1
fi
if ! grep -q 'random_pet\.server_name' *.tf; then
  echo "FAIL: Expected to find: random_pet\.server_name"
  exit 1
fi
if ! grep -q 'random_pet\.app_name' *.tf; then
  echo "FAIL: Expected to find: random_pet\.app_name"
  exit 1
fi
if ! grep -q 'local_file\.server_config' *.tf; then
  echo "FAIL: Expected to find: local_file\.server_config"
  exit 1
fi
if ! grep -q 'local_file\.app_config' *.tf; then
  echo "FAIL: Expected to find: local_file\.app_config"
  exit 1
fi

# Check new resource names exist
if ! grep -q 'resource "random_pet" "app_name"' *.tf; then
  echo "FAIL: Expected to find: resource "random_pet" "app_name""
  exit 1
fi
if ! grep -q 'resource "local_file" "app_config"' *.tf; then
  echo "FAIL: Expected to find: resource "local_file" "app_config""
  exit 1
fi

if ! terraform validate > /dev/null 2>&1; then
  echo "FAIL: terraform validate failed — check your HCL syntax"
  exit 1
fi
terraform plan -input=false > /dev/null 2>&1
echo "PASS: Moved blocks properly configured"
exit 0
