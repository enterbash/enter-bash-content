#!/bin/bash
set -e
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1

# Check moved blocks exist
grep -q 'moved' *.tf
grep -q 'random_pet\.server_name' *.tf
grep -q 'random_pet\.app_name' *.tf
grep -q 'local_file\.server_config' *.tf
grep -q 'local_file\.app_config' *.tf

# Check new resource names exist
grep -q 'resource "random_pet" "app_name"' *.tf
grep -q 'resource "local_file" "app_config"' *.tf

terraform validate > /dev/null 2>&1
terraform plan -input=false > /dev/null 2>&1
echo "PASS: Moved blocks properly configured"
exit 0
