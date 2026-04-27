#!/bin/bash
set -e
python3 ~/generate_deploy_data.py
echo "Ready: ~/deployments.json (15 deploys) and ~/incidents.json (8 incidents)."
