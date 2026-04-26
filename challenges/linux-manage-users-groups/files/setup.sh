#!/bin/bash
set -e

# Clean up any existing state
sudo userdel -r alice 2>/dev/null || true
sudo userdel -r bob 2>/dev/null || true
sudo groupdel devteam 2>/dev/null || true
sudo rm -rf /opt/project
