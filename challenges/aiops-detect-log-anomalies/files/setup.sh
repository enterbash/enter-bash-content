#!/bin/bash
set -e
python3 ~/generate_log_timeseries.py
echo "Ready. Write ~/detect_anomalies.py to find anomalous minutes in ~/log_counts.csv"
