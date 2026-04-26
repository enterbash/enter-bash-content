#!/bin/bash
set -e
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check correct types
grep -A2 'variable "app_name"' *.tf | grep -q 'type.*=.*string'
grep -A2 'variable "port"' *.tf | grep -q 'type.*=.*number'
grep -A2 'variable "allowed_hosts"' *.tf | grep -q 'list(string)'
grep -A2 'variable "feature_flags"' *.tf | grep -q 'object'

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Type constraints are correct"
exit 0
