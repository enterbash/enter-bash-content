#!/bin/bash
set -e

mkdir -p /home/runner/.ssh

# Create fake SSH files
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ runner@host" > /home/runner/.ssh/id_rsa.pub
echo "-----BEGIN OPENSSH PRIVATE KEY-----
fake_private_key_content
-----END OPENSSH PRIVATE KEY-----" > /home/runner/.ssh/id_rsa
echo "Host *
  ServerAliveInterval 60
  ServerAliveCountMax 3" > /home/runner/.ssh/config
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ runner@host" > /home/runner/.ssh/authorized_keys

# Set wrong permissions (too open)
chmod 777 /home/runner/.ssh
chmod 666 /home/runner/.ssh/id_rsa
chmod 666 /home/runner/.ssh/id_rsa.pub
chmod 666 /home/runner/.ssh/config
chmod 666 /home/runner/.ssh/authorized_keys

chown -R runner:runner /home/runner/.ssh
