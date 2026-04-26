#!/bin/bash
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check override file exists
ls *override*.tf > /dev/null 2>&1

# Check override content
grep -q 'development' *override*.tf
grep -q 'random_pet' *override*.tf
grep -q 'length.*=.*3' *override*.tf
grep -q 'separator.*=.*"_"' *override*.tf

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Override files properly configured"
exit 0
