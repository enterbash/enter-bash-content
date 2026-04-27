#!/bin/bash
set -e
python3 ~/generate_slo_data.py
echo "Ready: ~/request_data.csv has 1440 rows of per-minute request data."
