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

# Check provisioners exist
if ! grep -q 'null_resource' *.tf; then
  echo "FAIL: Expected to find: null_resource"
  exit 1
fi
if ! grep -q 'provisioner "local-exec"' *.tf; then
  echo "FAIL: Expected to find: provisioner "local-exec""
  exit 1
fi
if ! grep -q 'when.*=.*destroy' *.tf; then
  echo "FAIL: Expected to find: when.*=.*destroy"
  exit 1
fi
if ! grep -q 'provisioned' *.tf; then
  echo "FAIL: Expected to find: provisioned"
  exit 1
fi

# Apply and check provisioner ran
terraform apply -auto-approve -input=false > /dev/null 2>&1
test -f provisioned.txt

echo "PASS: Provisioners properly configured"
exit 0
