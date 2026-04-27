#!/bin/bash
set -e
python3 ~/generate_alerts.py
sudo mkdir -p /etc/alertmanager
echo "Ready: ~/raw_alerts.json has 52 alerts from a cascading DB failure."
