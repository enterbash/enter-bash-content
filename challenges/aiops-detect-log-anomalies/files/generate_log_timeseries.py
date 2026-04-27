#!/usr/bin/env python3
"""Generate per-minute log count time series with injected anomalies."""
import csv, random, math, datetime

random.seed(42)
base = datetime.datetime(2024, 1, 15, 0, 0, 0)
NORMAL_MEAN = 150
NORMAL_STD = 20

# Generate 1440 minutes (24 hours) with slight daily pattern
rows = []
anomaly_minutes = set()
# Inject 8 anomalies at random positions
for _ in range(4):
    anomaly_minutes.add(random.randint(60, 1380))  # spikes
for _ in range(4):
    anomaly_minutes.add(random.randint(60, 1380))  # drops

for i in range(1440):
    ts = base + datetime.timedelta(minutes=i)
    # Add slight daily seasonality (busier during work hours)
    hour = ts.hour
    seasonal = 30 * math.sin((hour - 6) * math.pi / 12) if 6 <= hour <= 18 else -10
    count = int(NORMAL_MEAN + seasonal + random.gauss(0, NORMAL_STD))
    count = max(10, count)

    if i in anomaly_minutes:
        if random.random() < 0.5:
            count = int(NORMAL_MEAN * random.uniform(3, 5))  # spike
        else:
            count = int(random.uniform(1, 10))  # drop

    rows.append({"minute": ts.strftime("%Y-%m-%dT%H:%M"), "count": count})

with open("/home/runner/log_counts.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["minute", "count"])
    w.writeheader()
    w.writerows(rows)

print(f"Generated {len(rows)} rows to ~/log_counts.csv ({len(anomaly_minutes)} anomalies injected)")
