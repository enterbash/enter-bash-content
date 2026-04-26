#!/bin/bash
cd ~/terraform-project
terraform init -input=false > /dev/null 2>&1
terraform validate > /dev/null 2>&1
echo "PASS: terraform validate succeeded"
exit 0
