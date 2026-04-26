#!/bin/bash
set -e

# Remove any existing SSH keys
rm -rf /home/runner/.ssh
mkdir -p /home/runner/.ssh
chmod 700 /home/runner/.ssh
chown -R runner:runner /home/runner/.ssh
