#!/bin/bash
set -e
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check count is used
grep -q 'count' *.tf
grep -q 'count\.index' *.tf
grep -q 'length(var\.environments)' *.tf

terraform plan -input=false > /dev/null 2>&1
PLAN_OUTPUT=$(terraform plan -input=false 2>&1)
echo "$PLAN_OUTPUT" | grep -q 'local_file.config\[0\]'
echo "$PLAN_OUTPUT" | grep -q 'local_file.config\[1\]'
echo "$PLAN_OUTPUT" | grep -q 'local_file.config\[2\]'

echo "PASS: Count meta-argument properly configured"
exit 0
