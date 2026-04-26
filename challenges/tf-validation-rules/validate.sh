#!/bin/bash
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1

# Check validation blocks exist
grep -c 'validation' *.tf | grep -q '[3-9]'
grep -q 'condition' *.tf
grep -q 'error_message' *.tf

# Valid defaults should pass
terraform plan -input=false > /dev/null 2>&1

# Invalid port should fail
if terraform plan -input=false -var="port=80" > /dev/null 2>&1; then
  echo "FAIL: Port validation should reject port 80"
  exit 1
fi

# Invalid environment should fail
if terraform plan -input=false -var="environment=invalid" > /dev/null 2>&1; then
  echo "FAIL: Environment validation should reject 'invalid'"
  exit 1
fi

echo "PASS: Validation rules properly configured"
exit 0
