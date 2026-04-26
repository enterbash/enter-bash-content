#!/bin/bash
wget -q https://releases.hashicorp.com/terraform/1.9.0/terraform_1.9.0_linux_amd64.zip -O /tmp/tf.zip && unzip -o /tmp/tf.zip -d /usr/local/bin/ && rm /tmp/tf.zip
mkdir -p ~/terraform-project/modules/config
