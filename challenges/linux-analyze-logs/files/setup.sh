#!/bin/bash
set -e

sudo mkdir -p /var/log/webapp
sudo chown "$(whoami):$(whoami)" /var/log/webapp

# Generate a realistic log file
cat > /tmp/gen_logs.py <<'PYTHON'
import random
import datetime

errors = [
    "ERROR: Database connection timeout after 30s",
    "ERROR: Failed to authenticate user: invalid token",
    "ERROR: Database connection timeout after 30s",
    "ERROR: Out of memory in worker pool",
    "ERROR: Database connection timeout after 30s",
    "ERROR: Failed to write to cache: connection refused",
]
warns = [
    "WARN: Slow query detected (>5s)",
    "WARN: Cache miss rate above 80%",
    "WARN: Memory usage above 90%",
    "WARN: Request queue depth > 100",
]
infos = [
    "INFO: Request processed successfully",
    "INFO: User login successful",
    "INFO: Cache refreshed",
    "INFO: Health check passed",
    "INFO: Background job completed",
]

base = datetime.datetime(2024, 3, 15, 0, 0, 0)
lines = []
for i in range(500):
    ts = base + datetime.timedelta(minutes=i*2)
    r = random.random()
    if r < 0.15:
        msg = random.choice(errors)
    elif r < 0.30:
        msg = random.choice(warns)
    else:
        msg = random.choice(infos)
    lines.append(f"[{ts.isoformat()}] {msg}")

with open("/var/log/webapp/app.log", "w") as f:
    f.write("\n".join(lines) + "\n")
PYTHON

python3 /tmp/gen_logs.py
rm -f /tmp/gen_logs.py
rm -f /home/runner/log-analysis.txt
