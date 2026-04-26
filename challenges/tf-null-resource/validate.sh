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

if ! grep -q 'null_resource.*config_generator' *.tf; then
  echo "FAIL: Expected to find: null_resource.*config_generator"
  exit 1
fi
if ! grep -q 'null_resource.*always_run' *.tf; then
  echo "FAIL: Expected to find: null_resource.*always_run"
  exit 1
fi
if ! grep -q 'triggers' *.tf; then
  echo "FAIL: Expected to find: triggers"
  exit 1
fi
if ! grep -q 'config_version' *.tf; then
  echo "FAIL: Expected to find: config_version"
  exit 1
fi
if ! grep -q 'timestamp()' *.tf; then
  echo "FAIL: Expected to find: timestamp()"
  exit 1
fi
if ! grep -q 'provisioner "local-exec"' *.tf; then
  echo "FAIL: Expected to find: provisioner "local-exec""
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
echo "PASS: null_resource triggers properly configured"
exit 0
