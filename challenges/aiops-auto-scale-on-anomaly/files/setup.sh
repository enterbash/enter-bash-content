#!/bin/bash
set -e
python3 ~/generate_latency_stream.py
echo "Ready: ~/latency_stream.csv has 60 rows (1/min) with 5 anomalous spikes."
