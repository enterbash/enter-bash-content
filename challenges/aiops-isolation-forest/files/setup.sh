#!/bin/bash
set -e
python3 ~/generate_multi_metrics.py
echo "Ready. Write ~/isolation_forest.py to detect anomalies in ~/server_metrics.csv"
