#!/bin/bash
set -e

# Load dummy module
sudo modprobe dummy 2>/dev/null || true

# Create dummy interface with wrong IP
sudo ip link add dummy0 type dummy 2>/dev/null || true
sudo ip addr flush dev dummy0
sudo ip addr add 192.168.99.99/24 dev dummy0
sudo ip link set dummy0 down
