#!/bin/bash
set -e
python3 ~/generate_baseline_data.py
echo "Ready: ~/baseline_data.csv (168 rows) and ~/new_data.csv (24 rows with 3 anomalies)."
