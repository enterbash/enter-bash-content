#!/bin/bash
set -e

# Create the shared directory with test data
mkdir -p /srv/nfs/shared
echo "NFS test file" > /srv/nfs/shared/testfile.txt
echo "shared data" > /srv/nfs/shared/data.txt

# Create mount point
mkdir -p /mnt/nfs-test

# Clear any existing exports
echo "" | sudo tee /etc/exports > /dev/null

# Stop NFS server if running
service nfs-kernel-server stop 2>/dev/null || true
