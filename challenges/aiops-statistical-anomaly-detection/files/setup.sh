#!/bin/bash
set -e
python3 ~/generate_cpu_data.py
echo "Ready. Write ~/anomaly_detector.py to detect anomalies in ~/cpu_metrics.csv"
