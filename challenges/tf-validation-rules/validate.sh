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

# Check validation blocks exist
if ! grep -c 'validation' *.tf | grep -q '[3-9]'; then
  echo "FAIL: Expected at least 3 validation blocks in your .tf files"
  exit 1
fi
if ! grep -q 'condition' *.tf; then
  echo "FAIL: Expected to find: condition"
  exit 1
fi
if ! grep -q 'error_message' *.tf; then
  echo "FAIL: Expected to find: error_message"
  exit 1
fi

# Valid defaults should pass
EXIT_CODE=0
terraform plan -input=false > /dev/null 2>&1 || EXIT_CODE=$?
if [ "$EXIT_CODE" -eq 2 ]; then
  echo "FAIL: terraform plan shows pending changes — your config may be incomplete"
  exit 1
elif [ "$EXIT_CODE" -ne 0 ]; then
  echo "FAIL: terraform plan encountered an error"
  exit 1
fi

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
