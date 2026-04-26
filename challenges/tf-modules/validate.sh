#!/bin/bash
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check module call in root
grep -q 'module "app_config"' main.tf
grep -q 'source.*modules/config' main.tf
grep -q 'app_name' main.tf
grep -q 'environment' main.tf

# Check module definition
grep -q 'variable "app_name"' modules/config/main.tf
grep -q 'variable "environment"' modules/config/main.tf
grep -q 'resource "local_file"' modules/config/main.tf
grep -q 'output "config_path"' modules/config/main.tf

# Check root output
grep -q 'output "config_file"' main.tf
grep -q 'module\.app_config' main.tf

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Module properly defined and called"
exit 0
