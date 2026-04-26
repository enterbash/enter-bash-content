#!/bin/bash
set -e

# Create the log directory and a large log file
sudo mkdir -p /var/log/myapp
sudo dd if=/dev/urandom of=/var/log/myapp/app.log bs=1M count=50 2>/dev/null
sudo chmod 644 /var/log/myapp/app.log

# Remove any existing logrotate config for myapp
rm -f /etc/logrotate.d/myapp
