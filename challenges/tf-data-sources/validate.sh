#!/bin/bash
set -e
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check data sources exist
grep -q 'data "local_file" "source_config"' *.tf
grep -q 'data "local_file" "source_version"' *.tf

# Check combined resource exists
grep -q 'resource "local_file" "combined"' *.tf

# Check data sources are referenced
grep -q 'data\.local_file\.source_config' *.tf
grep -q 'data\.local_file\.source_version' *.tf

terraform plan -input=false > /dev/null 2>&1
echo "PASS: Data sources properly configured"
exit 0
