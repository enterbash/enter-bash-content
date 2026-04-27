#!/bin/bash
set -e
python3 ~/generate_varied_logs.py
echo "Ready. Write ~/cluster_logs.py to cluster ~/varied.log using drain3."
