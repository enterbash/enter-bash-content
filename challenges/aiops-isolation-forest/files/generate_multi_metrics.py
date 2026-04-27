#!/usr/bin/env python3
"""Generate multi-dimensional server metrics with correlated anomalies."""
import csv, random, math, datetime

random.seed(42)
base = datetime.datetime(2024, 1, 15, 0, 0, 0)
rows = []
anomaly_indices = set()
for _ in range(72):
    anomaly_indices.add(random.randint(30, 1410))

for i in range(1440):
    ts = base + datetime.timedelta(minutes=i)
    hour = ts.hour
    load = 0.5 + 0.3 * math.sin((hour - 6) * math.pi / 12) if 6 <= hour <= 22 else 0.3
    cpu = 30 + load * 40 + random.gauss(0, 5)
    mem = 40 + load * 30 + random.gauss(0, 4)
    net = int(500000 + load * 1000000 + random.gauss(0, 100000))
    disk = 5 + load * 15 + random.gauss(0, 3)
    if i in anomaly_indices:
        r = random.random()
        if r < 0.25:
            cpu = random.uniform(85, 99); mem = random.uniform(20, 30)
        elif r < 0.5:
            disk = random.uniform(200, 500); cpu = random.uniform(10, 20)
        elif r < 0.75:
            net = int(random.uniform(5000000, 10000000)); mem = random.uniform(90, 99)
        else:
            cpu = random.uniform(1, 5); mem = random.uniform(1, 5)
    rows.append({
        "timestamp": ts.strftime("%Y-%m-%dT%H:%M"),
        "cpu_percent": round(max(0, min(100, cpu)), 1),
        "memory_percent": round(max(0, min(100, mem)), 1),
        "network_bytes_sec": max(0, net),
        "disk_io_ms": round(max(0, disk), 1)
    })

with open("/home/runner/server_metrics.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["timestamp", "cpu_percent", "memory_percent", "network_bytes_sec", "disk_io_ms"])
    w.writeheader()
    w.writerows(rows)
print(f"Generated {len(rows)} rows ({len(anomaly_indices)} anomalies)")
