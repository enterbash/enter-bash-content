#!/usr/bin/env python3
"""Generate 30 days of daily disk usage with steady growth."""
import csv, random, datetime

random.seed(42)
base = datetime.datetime(2024, 1, 1)
usage = 62.0
rows = []
for i in range(30):
    ts = base + datetime.timedelta(days=i)
    usage += random.uniform(0.3, 0.7) + 0.1 * (i / 30)
    rows.append({"ds": ts.strftime("%Y-%m-%d"), "y": round(usage, 1)})

with open("/home/runner/disk_usage.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["ds", "y"])
    w.writeheader()
    w.writerows(rows)
print(f"Generated {len(rows)} days, current usage: {rows[-1]['y']}%")
