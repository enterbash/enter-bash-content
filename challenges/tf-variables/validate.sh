#!/bin/bash
set -e
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check that variables are defined
grep -q 'variable "project_name"' *.tf
grep -q 'variable "environment"' *.tf
grep -q 'variable "file_count"' *.tf

# Check that variables are used
grep -q 'var\.project_name' *.tf
grep -q 'var\.environment' *.tf
grep -q 'var\.file_count' *.tf

# Check defaults
grep -A5 'variable "project_name"' *.tf | grep -q 'default.*"my-app"'
grep -A5 'variable "environment"' *.tf | grep -q 'default.*"staging"'
grep -A5 'variable "file_count"' *.tf | grep -q 'default.*3'

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Variables properly defined and used"
exit 0
