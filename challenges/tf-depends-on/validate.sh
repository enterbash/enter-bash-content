#!/bin/bash
set -e
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check depends_on exists
grep -q 'depends_on' *.tf
grep -A2 'depends_on' *.tf | grep -q 'null_resource\.create_dir'
grep -A2 'depends_on' *.tf | grep -q 'local_file\.app_config'

# Apply should succeed with correct ordering
terraform apply -auto-approve -input=false > /dev/null 2>&1

echo "PASS: Dependencies properly ordered"
exit 0
