#!/bin/bash
set -e
python3 ~/generate_messy_logs.py
echo "Ready. Write ~/extract_errors.py to analyze ~/application.log"
