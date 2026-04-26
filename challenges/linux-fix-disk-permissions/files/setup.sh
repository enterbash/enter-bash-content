#!/bin/bash
set -e

# Create a disk image and mount it
dd if=/dev/zero of=/opt/data-disk.img bs=1M count=64 2>/dev/null
mkfs.ext4 -F /opt/data-disk.img > /dev/null 2>&1
mkdir -p /mnt/data
mount -o loop /opt/data-disk.img /mnt/data

# Set restrictive permissions (root only)
chown root:root /mnt/data
chmod 700 /mnt/data
