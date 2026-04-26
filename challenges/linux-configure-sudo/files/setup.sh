#!/bin/bash
set -e

# Create the developer user
sudo useradd -m developer 2>/dev/null || true

# Remove any existing sudoers config
sudo rm -f /etc/sudoers.d/developer
