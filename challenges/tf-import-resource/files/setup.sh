#!/bin/bash
mkdir -p ~/terraform-project

# Create a local file that exists outside terraform
mkdir -p ~/terraform-project
echo "app_version=2.1.0" > ~/terraform-project/app-config.txt
