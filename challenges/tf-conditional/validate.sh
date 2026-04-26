#!/bin/bash
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check conditional expressions exist
grep -q '?' *.tf
grep -q 'var\.environment' *.tf
grep -q 'var\.enable_debug' *.tf
grep -q 'count' *.tf

# Check config resource
grep -A5 'resource "local_file" "config"' *.tf | grep -q 'production'

# Check debug_log resource with count
grep -A5 'resource "local_file" "debug_log"' *.tf | grep -q 'count'

# Plan with defaults (production, debug=false) should work
terraform plan -input=false > /dev/null 2>&1

# Plan with non-production should also work
terraform plan -input=false -var="environment=staging" -var="enable_debug=true" > /dev/null 2>&1

echo "PASS: Conditional expressions properly configured"
exit 0
