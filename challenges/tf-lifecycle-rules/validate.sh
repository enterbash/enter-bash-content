#!/bin/bash
set -e
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check lifecycle blocks exist
grep -q 'lifecycle' *.tf
grep -q 'create_before_destroy.*=.*true' *.tf
grep -q 'ignore_changes' *.tf
grep -q 'content' *.tf
grep -q 'prevent_destroy.*=.*true' *.tf

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Lifecycle rules properly configured"
exit 0
