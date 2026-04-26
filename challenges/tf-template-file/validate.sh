#!/bin/bash
set -e
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

grep -q 'templatefile' *.tf
grep -q 'config\.tftpl' *.tf
grep -q 'app_name' *.tf
grep -q 'environment' *.tf
grep -q 'ports' *.tf

terraform plan -input=false > /dev/null 2>&1
echo "PASS: templatefile properly configured"
exit 0
