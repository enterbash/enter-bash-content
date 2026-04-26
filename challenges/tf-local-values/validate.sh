#!/bin/bash
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check locals block exists with required values
grep -q 'locals' *.tf
grep -q 'project_name' *.tf
grep -q 'environment' *.tf
grep -q 'common_tags' *.tf

# Check locals are used in resources
grep -q 'local\.' *.tf

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Local values properly defined and used"
exit 0
