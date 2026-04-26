#!/bin/bash
set -e

# Ensure no swap is active
sudo swapoff -a 2>/dev/null || true
rm -f /swapfile

# Remove any swap entries from fstab
sudo sed -i '/swap/d' /etc/fstab 2>/dev/null || true
