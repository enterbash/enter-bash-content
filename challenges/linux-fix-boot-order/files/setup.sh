#!/bin/bash
set -e

# Create a broken GRUB config
mkdir -p /etc/default
cat > /etc/default/grub <<'EOF'
# Broken GRUB configuration
GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_CMDLINE_LINUX_DEFAULT="nosplash panic=0 noquiet"
GRUB_CMDLINE_LINUX="crashkernel=auto rhgb"
GRUB_DISABLE_RECOVERY="true"
EOF
