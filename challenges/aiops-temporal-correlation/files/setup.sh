#!/bin/bash
set -e
python3 ~/generate_events.py
echo "Ready: ~/events.json has 85 events from 6 services (4 incident clusters + noise)."
