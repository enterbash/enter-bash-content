#!/bin/bash
set -e
python3 ~/generate_alert_history.py
echo "Ready: ~/alert_history.csv (500 rows) and ~/new_alerts.csv (50 rows)."
