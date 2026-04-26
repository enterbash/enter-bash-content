#!/bin/bash
set -e

# Create the developer user
useradd -m developer 2>/dev/null || true

# Remove any existing sudoers config
rm -f /etc/sudoers.d/developer
