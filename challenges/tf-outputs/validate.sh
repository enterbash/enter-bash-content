#!/bin/bash
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check outputs exist
grep -q 'output "pet_name"' *.tf
grep -q 'output "config_path"' *.tf
grep -q 'output "random_number"' *.tf

# Check output values reference correct resources
grep -A3 'output "pet_name"' *.tf | grep -q 'random_pet\.server\.id'
grep -A3 'output "config_path"' *.tf | grep -q 'local_file\.config\.filename'
grep -A3 'output "random_number"' *.tf | grep -q 'random_integer\.priority\.result'

# Check description on random_number
grep -A5 'output "random_number"' *.tf | grep -q 'description'

terraform plan -input=false > /dev/null 2>&1
echo "PASS: All outputs properly defined"
exit 0
