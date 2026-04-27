#!/bin/bash
set -e
python3 ~/generate_seasonal_data.py
echo "Ready. Write ~/decompose.py to perform STL decomposition on ~/request_rate.csv"
