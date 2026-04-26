#!/bin/bash
cd ~/terraform-project
if ! terraform init -input=false > /dev/null 2>&1; then
  echo "FAIL: terraform init failed — check provider configuration"
  exit 1
fi
if ! terraform validate > /dev/null 2>&1; then
  echo "FAIL: terraform validate failed — check your HCL syntax"
  exit 1
fi

# Check proper interpolation syntax
if ! grep -q '${var\.project}' *.tf; then
  echo "FAIL: Expected to find: ${var\.project}"
  exit 1
fi
if ! grep -q '${var\.region}' *.tf; then
  echo "FAIL: Expected to find: ${var\.region}"
  exit 1
fi
if ! grep -q '${random_id\.suffix\.hex}' *.tf; then
  echo "FAIL: Expected to find: ${random_id\.suffix\.hex}"
  exit 1
fi
if ! grep -q '${path\.module}' *.tf; then
  echo "FAIL: Expected to find: ${path\.module}"
  exit 1
fi

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
