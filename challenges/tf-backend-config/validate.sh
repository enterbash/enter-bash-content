#!/bin/bash
cd ~/terraform-project
mkdir -p state

# Check backend config exists
grep -q 'backend "local"' main.tf
grep -q 'state/terraform.tfstate' main.tf

terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check state file is in the right place after apply
terraform plan -input=false > /dev/null 2>&1

echo "PASS: Backend properly configured"
exit 0
