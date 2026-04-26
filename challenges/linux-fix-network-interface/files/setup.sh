#!/bin/bash
set -e

# Load dummy module
modprobe dummy 2>/dev/null || true

# Create dummy interface with wrong IP
ip link add dummy0 type dummy 2>/dev/null || true
ip addr flush dev dummy0
ip addr add 192.168.99.99/24 dev dummy0
ip link set dummy0 down
