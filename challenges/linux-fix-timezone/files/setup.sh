#!/bin/bash
set -e

# Set a wrong timezone
ln -sf /usr/share/zoneinfo/Pacific/Kiritimati /etc/localtime
echo "Pacific/Kiritimati" | sudo tee /etc/timezone > /dev/null
