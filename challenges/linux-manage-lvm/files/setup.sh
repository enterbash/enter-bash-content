#!/bin/bash
set -e

# Create loop devices for LVM
sudo dd if=/dev/zero of=/opt/lvm-disk1.img bs=1M count=128 2>/dev/null
sudo dd if=/dev/zero of=/opt/lvm-disk2.img bs=1M count=128 2>/dev/null

LOOP1=$(sudo losetup --find --show /opt/lvm-disk1.img)
LOOP2=$(sudo losetup --find --show /opt/lvm-disk2.img)

# Create PVs
sudo pvcreate "$LOOP1" "$LOOP2"

# Create VG with both PVs
sudo vgcreate vg_data "$LOOP1" "$LOOP2"

# Create a small LV (only 64MB out of ~256MB available)
sudo lvcreate -L 64M -n lv_app vg_data

# Create filesystem and mount
sudo mkfs.ext4 -F /dev/vg_data/lv_app > /dev/null 2>&1
sudo mkdir -p /mnt/appdata
sudo mount /dev/vg_data/lv_app /mnt/appdata
echo "application data" | sudo tee /mnt/appdata/data.txt > /dev/null
