#!/bin/bash
set -e
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check dynamic block exists
grep -q 'dynamic "provisioner"' *.tf || grep -q 'dynamic "provisioner"' *.tf
grep -q 'for_each' *.tf
grep -q 'content' *.tf
grep -q 'provisioner\.value' *.tf

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Dynamic blocks properly configured"
exit 0
