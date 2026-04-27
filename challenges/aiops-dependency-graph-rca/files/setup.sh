#!/bin/bash
set -e
python3 ~/generate_graph.py
echo "Ready: ~/service_graph.json (12 services) and ~/failing_services.json (5 failing)."
