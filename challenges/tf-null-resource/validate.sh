#!/bin/bash
set -e
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

grep -q 'null_resource.*config_generator' *.tf
grep -q 'null_resource.*always_run' *.tf
grep -q 'triggers' *.tf
grep -q 'config_version' *.tf
grep -q 'timestamp()' *.tf
grep -q 'provisioner "local-exec"' *.tf

terraform plan -input=false > /dev/null 2>&1
echo "PASS: null_resource triggers properly configured"
exit 0
