#!/bin/bash
set -e

# Create old log files
sudo mkdir -p /var/log/myapp
for i in $(seq 1 10); do
  sudo dd if=/dev/urandom of=/var/log/myapp/app-2024-01-${i}.log.old bs=1M count=10 2>/dev/null
done
sudo dd if=/dev/urandom of=/var/log/myapp/app-current.log bs=1K count=50 2>/dev/null

# Create build cache
mkdir -p /tmp/build-cache
for i in $(seq 1 5); do
  dd if=/dev/zero of=/tmp/build-cache/layer-${i}.tar bs=1M count=20 2>/dev/null
done

# Create old downloads
mkdir -p /home/runner/downloads
for pkg in libfoo libbar libbaz; do
  dd if=/dev/zero of=/home/runner/downloads/${pkg}_1.0_amd64.deb bs=1M count=15 2>/dev/null
done
echo "important-notes.txt" > /home/runner/downloads/notes.txt
