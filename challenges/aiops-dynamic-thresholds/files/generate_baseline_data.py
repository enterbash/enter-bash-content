#!/usr/bin/env python3
"""Generate baseline (7d hourly) and new (24h) latency data with anomalies."""
import csv, random, math

random.seed(42)

# Baseline: 168 rows (7 days * 24 hours), daily pattern
baseline = []
for i in range(168):
    hour = i % 24
    # Daily pattern: low at night (2-6am), high during day (10am-4pm)
    if 2 <= hour <= 6:
        base_latency = 20 + 5 * math.sin((hour - 2) * math.pi / 4)
    elif 10 <= hour <= 16:
        base_latency = 80 + 20 * math.sin((hour - 10) * math.pi / 6)
    else:
        base_latency = 45 + 10 * math.sin(hour * math.pi / 12)
    latency = base_latency + random.gauss(0, 3)
    latency = max(5, round(latency, 1))
    baseline.append({"hour": i, "hour_of_day": hour, "latency_ms": latency})

with open("/home/runner/baseline_data.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["hour", "hour_of_day", "latency_ms"])
    w.writeheader()
    w.writerows(baseline)

# New data: 24 rows with 3 injected anomalies
anomaly_hours = {5, 13, 20}  # inject at these hours
new_data = []
for h in range(24):
    if h in anomaly_hours:
        # Anomaly: 3-5x normal for that hour
        normal = baseline[h]["latency_ms"]
        latency = round(normal * random.uniform(3.0, 5.0), 1)
    else:
        base_latency = baseline[h]["latency_ms"]
        latency = round(base_latency + random.gauss(0, 3), 1)
    latency = max(5, latency)
    new_data.append({"hour": h, "hour_of_day": h, "latency_ms": latency})

with open("/home/runner/new_data.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["hour", "hour_of_day", "latency_ms"])
    w.writeheader()
    w.writerows(new_data)

print(f"Generated baseline_data.csv ({len(baseline)} rows) and new_data.csv ({len(new_data)} rows, 3 anomalies)")
