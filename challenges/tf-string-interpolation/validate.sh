#!/bin/bash
set -e
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check proper interpolation syntax
grep -q '${var\.project}' *.tf
grep -q '${var\.region}' *.tf
grep -q '${random_id\.suffix\.hex}' *.tf
grep -q '${path\.module}' *.tf

# Should not have bare $var references
! grep -q '\$var\.' *.tf 2>/dev/null || {
  # Check it's always inside ${}
  if grep -P '\$var\.' *.tf | grep -vP '\$\{var\.' > /dev/null 2>&1; then
    echo "FAIL: Found bare \$var. references without \${}"
    exit 1
  fi
}

terraform plan -input=false > /dev/null 2>&1
echo "PASS: String interpolation is correct"
exit 0
