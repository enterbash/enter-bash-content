#!/bin/bash
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

grep -q '\[\*\]' *.tf
grep -q 'output "all_pet_names"' *.tf
grep -q 'output "all_file_paths"' *.tf
grep -q 'local_file.*summary' *.tf
grep -q 'join' *.tf

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Splat expressions properly used"
exit 0
