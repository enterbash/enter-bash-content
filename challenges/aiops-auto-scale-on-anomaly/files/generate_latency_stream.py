#!/usr/bin/env python3
"""Generate latency stream CSV with 60 rows (1/min) and 5 anomalous spikes."""
import csv, random

random.seed(42)
anomaly_minutes = {12, 27, 38, 45, 53}
rows = []
for minute in range(60):
    if minute in anomaly_minutes:
        latency = round(random.uniform(800, 2000), 1)
    else:
        latency = round(random.gauss(120, 25), 1)
        latency = max(30, latency)
    rows.append({"minute": minute, "latency_ms": latency})

with open("/home/runner/latency_stream.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["minute", "latency_ms"])
    w.writeheader()
    w.writerows(rows)
print(f"Generated {len(rows)} rows (5 anomalous spikes) to ~/latency_stream.csv")
