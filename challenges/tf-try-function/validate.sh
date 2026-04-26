#!/bin/bash
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

grep -q 'try(' *.tf
grep -q 'can(' *.tf
grep -q 'default-app' *.tf
grep -q '8080' *.tf
grep -q 'localhost' *.tf

terraform plan -input=false > /dev/null 2>&1
echo "PASS: try and can functions properly used"
exit 0
