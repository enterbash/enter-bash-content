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

# Check data sources exist
if ! grep -q 'data "local_file" "source_config"' *.tf; then
  echo "FAIL: Expected to find: data "local_file" "source_config""
  exit 1
fi
if ! grep -q 'data "local_file" "source_version"' *.tf; then
  echo "FAIL: Expected to find: data "local_file" "source_version""
  exit 1
fi

# Check combined resource exists
if ! grep -q 'resource "local_file" "combined"' *.tf; then
  echo "FAIL: Expected to find: resource "local_file" "combined""
  exit 1
fi

# Check data sources are referenced
if ! grep -q 'data\.local_file\.source_config' *.tf; then
  echo "FAIL: Expected to find: data\.local_file\.source_config"
  exit 1
fi
if ! grep -q 'data\.local_file\.source_version' *.tf; then
  echo "FAIL: Expected to find: data\.local_file\.source_version"
  exit 1
fi

EXIT_CODE=0
terraform plan -input=false > /dev/null 2>&1 || EXIT_CODE=$?
if [ "$EXIT_CODE" -eq 2 ]; then
  echo "FAIL: terraform plan shows pending changes — your config may be incomplete"
  exit 1
elif [ "$EXIT_CODE" -ne 0 ]; then
  echo "FAIL: terraform plan encountered an error"
  exit 1
fi
echo "PASS: Data sources properly configured"
exit 0
