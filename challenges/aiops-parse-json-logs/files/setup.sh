#!/bin/bash
set -e
python3 ~/generate_logs.py
echo "Ready. Analyze ~/webservice.log using jq."
