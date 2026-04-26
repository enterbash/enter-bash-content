#!/bin/bash
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check sensitive markers
grep -A5 'variable "db_password"' *.tf | grep -q 'sensitive.*=.*true'
grep -A5 'variable "api_key"' *.tf | grep -q 'sensitive.*=.*true'

# Check outputs
grep -q 'output "app_id"' *.tf
grep -q 'output "password_set"' *.tf
grep -A5 'output "password_set"' *.tf | grep -q 'sensitive.*=.*true'

# Check config resource
grep -q 'local_file.*config' *.tf

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Sensitive variables properly handled"
exit 0
