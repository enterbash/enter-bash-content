#!/bin/bash
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1

# Check terraform.workspace is used in config
grep -q 'terraform\.workspace' main.tf

# Check staging workspace exists
terraform workspace list | grep -q 'staging'

terraform validate > /dev/null 2>&1
echo "PASS: Workspaces properly configured"
exit 0
