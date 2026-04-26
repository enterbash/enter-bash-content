#!/bin/bash
set -e

# Create a disk image with ext4 filesystem
dd if=/dev/zero of=/opt/disk.img bs=1M count=64 2>/dev/null
mkfs.ext4 -F /opt/disk.img > /dev/null 2>&1

# Add a broken fstab entry (wrong device, wrong fs type)
echo "/dev/sdz99  /mnt/data  ntfs  defaults  0  0" | sudo tee -a /etc/fstab > /dev/null

# Don't create the mount point (part of the challenge)
