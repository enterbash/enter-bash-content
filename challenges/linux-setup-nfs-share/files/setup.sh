#!/bin/bash
set -e

# Create the shared directory with test data
sudo mkdir -p /srv/nfs/shared
echo "NFS test file" | sudo tee /srv/nfs/shared/testfile.txt > /dev/null
echo "shared data" | sudo tee /srv/nfs/shared/data.txt > /dev/null

# Create mount point
sudo mkdir -p /mnt/nfs-test

# Clear any existing exports
echo "" | sudo tee /etc/exports > /dev/null

# Stop NFS server if running
service nfs-kernel-server stop 2>/dev/null || true
