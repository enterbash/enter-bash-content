#!/bin/bash
set -e
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

grep -q 'for_each' *.tf
grep -q 'each\.key' *.tf
grep -q 'each\.value' *.tf
grep -q 'var\.services' *.tf

PLAN_OUTPUT=$(terraform plan -input=false 2>&1)
echo "$PLAN_OUTPUT" | grep -q 'local_file.service_config\["web"\]'
echo "$PLAN_OUTPUT" | grep -q 'local_file.service_config\["api"\]'
echo "$PLAN_OUTPUT" | grep -q 'local_file.service_config\["worker"\]'

echo "PASS: for_each properly configured"
exit 0
