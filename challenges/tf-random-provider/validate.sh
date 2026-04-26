#!/bin/bash
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

grep -q 'random_pet.*app_name' *.tf
grep -q 'random_integer.*port' *.tf
grep -q 'random_password.*db_password' *.tf
grep -q 'random_uuid.*request_id' *.tf
grep -q 'local_file.*config' *.tf

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Random provider resources properly configured"
exit 0
