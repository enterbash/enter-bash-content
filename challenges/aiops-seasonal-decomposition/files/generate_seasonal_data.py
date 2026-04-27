#!/usr/bin/env python3
"""Generate hourly request rate with daily seasonality and anomalies."""
import csv, random, math, datetime

random.seed(42)
base = datetime.datetime(2024, 1, 15, 0, 0, 0)
rows = []
anomaly_hours = set()
for _ in range(5):
    anomaly_hours.add(random.randint(10, 160))

for i in range(168):  # 7 days * 24 hours
    ts = base + datetime.timedelta(hours=i)
    hour = ts.hour
    seasonal = 400 * math.sin((hour - 4) * math.pi / 12) if 4 <= hour <= 22 else -200
    trend = 1200 + i * 1.5
    noise = random.gauss(0, 40)
    requests = int(trend + seasonal + noise)
    if i in anomaly_hours:
        if random.random() < 0.6:
            requests = int(requests * random.uniform(2.5, 4))
        else:
            requests = int(requests * random.uniform(0.05, 0.2))
    rows.append({"timestamp": ts.strftime("%Y-%m-%dT%H:%M"), "requests": max(0, requests)})

with open("/home/runner/request_rate.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["timestamp", "requests"])
    w.writeheader()
    w.writerows(rows)
print(f"Generated {len(rows)} rows ({len(anomaly_hours)} anomalies)")
