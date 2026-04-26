#!/bin/bash
set -e
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check provisioners exist
grep -q 'null_resource' *.tf
grep -q 'provisioner "local-exec"' *.tf
grep -q 'when.*=.*destroy' *.tf
grep -q 'provisioned' *.tf

# Apply and check provisioner ran
terraform apply -auto-approve -input=false > /dev/null 2>&1
test -f provisioned.txt

echo "PASS: Provisioners properly configured"
exit 0
