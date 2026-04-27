#!/usr/bin/env python3
"""Generate request data CSV with per-minute totals and errors for 24h."""
import csv, random, math

random.seed(42)
rows = []
for minute in range(1440):
    hour = minute // 60
    # Base traffic: higher during business hours
    base = 800 + 400 * math.sin((hour - 6) * math.pi / 12) if 6 <= hour <= 22 else 400
    total = int(base + random.gauss(0, 50))
    total = max(100, total)
    # Normal error rate ~0.1%
    error_rate = 0.001 + random.gauss(0, 0.0003)
    # Inject spikes at specific minutes
    if minute in (347, 348, 349, 890, 891, 1100, 1101, 1102, 1103):
        error_rate = random.uniform(0.02, 0.08)
    error_rate = max(0, error_rate)
    errors = int(total * error_rate)
    rows.append({"minute": minute, "total_requests": total, "error_requests": errors})

with open("/home/runner/request_data.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["minute", "total_requests", "error_requests"])
    w.writeheader()
    w.writerows(rows)
print(f"Generated {len(rows)} rows to ~/request_data.csv")
