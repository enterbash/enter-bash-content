#!/usr/bin/env python3
"""Generate a realistic JSON log file for analysis."""
import json, random, time, datetime

random.seed(42)
base = datetime.datetime(2024, 1, 15, 0, 0, 0)
paths = ["/api/users", "/api/orders", "/api/products", "/api/health", "/api/search", "/api/auth", "/api/payments"]
methods = ["GET", "GET", "GET", "POST", "PUT", "DELETE"]
users = [f"user_{i:04d}" for i in range(50)]

lines = []
for i in range(500):
    ts = base + datetime.timedelta(seconds=i * 6 + random.randint(0, 5))
    status = random.choices([200, 201, 204, 301, 400, 401, 403, 404, 500, 502, 503], weights=[50, 10, 5, 3, 8, 4, 3, 6, 5, 3, 3])[0]
    latency = random.randint(5, 150)
    if status >= 500:
        latency = random.randint(200, 2000)
    if random.random() < 0.05:
        latency = random.randint(1500, 5000)
    entry = {
        "timestamp": ts.isoformat() + "Z",
        "method": random.choice(methods),
        "path": random.choice(paths),
        "status": status,
        "latency_ms": latency,
        "user_id": random.choice(users)
    }
    lines.append(json.dumps(entry))

with open("/home/runner/webservice.log", "w") as f:
    f.write("\n".join(lines) + "\n")
print(f"Generated {len(lines)} log entries to ~/webservice.log")
