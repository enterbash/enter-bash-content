#!/usr/bin/env python3
"""Generate CPU metrics CSV with injected anomalies."""
import csv, random, math, datetime

random.seed(42)
base = datetime.datetime(2024, 1, 15, 0, 0, 0)
rows = []
anomaly_indices = set()
for _ in range(12):
    anomaly_indices.add(random.randint(50, 1960))

for i in range(2016):  # 7 days * 24h * 12 (5-min intervals)
    ts = base + datetime.timedelta(minutes=i * 5)
    hour = ts.hour
    seasonal = 10 * math.sin((hour - 6) * math.pi / 12) if 6 <= hour <= 22 else -5
    cpu = 45 + seasonal + random.gauss(0, 5)
    if i in anomaly_indices:
        if random.random() < 0.5:
            cpu = random.uniform(85, 99)
        else:
            cpu = random.uniform(1, 8)
    cpu = max(0, min(100, cpu))
    rows.append({"timestamp": ts.strftime("%Y-%m-%dT%H:%M:%S"), "cpu_percent": round(cpu, 1)})

with open("/home/runner/cpu_metrics.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["timestamp", "cpu_percent"])
    w.writeheader()
    w.writerows(rows)
print(f"Generated {len(rows)} rows ({len(anomaly_indices)} anomalies)")
