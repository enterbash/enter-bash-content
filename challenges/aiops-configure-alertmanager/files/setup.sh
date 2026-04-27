#!/bin/bash
# Setup for aiops-configure-alertmanager
set -e
sudo mkdir -p /etc/alertmanager
# Leave config empty — user needs to create it
echo "Ready. Create /etc/alertmanager/alertmanager.yml with routing rules."
