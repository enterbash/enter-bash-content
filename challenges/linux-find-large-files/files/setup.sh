#!/bin/bash
set -e

# Create large junk files scattered across various directories
mkdir -p /home/runner/.cache/old-builds
mkdir -p /home/runner/projects/legacy/data
mkdir -p /home/runner/.local/share/trash
mkdir -p /home/runner/backups/2023

dd if=/dev/zero of=/home/runner/.cache/old-builds/build-artifact.tar bs=1M count=150 2>/dev/null
dd if=/dev/zero of=/home/runner/projects/legacy/data/dump.sql bs=1M count=200 2>/dev/null
dd if=/dev/zero of=/home/runner/.local/share/trash/old-video.mp4 bs=1M count=120 2>/dev/null
dd if=/dev/zero of=/home/runner/backups/2023/full-backup.tar.gz bs=1M count=180 2>/dev/null
dd if=/dev/zero of=/home/runner/core.dump bs=1M count=250 2>/dev/null
