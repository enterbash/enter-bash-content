#!/bin/bash
set -e
python3 ~/generate_disk_data.py
echo "Ready. Write ~/forecast.py to predict when disk hits 90% using Prophet."
