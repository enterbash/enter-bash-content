#!/usr/bin/env python3
"""Generate 85 events from 6 services with 4 incident clusters + noise."""
import json, random, datetime

random.seed(42)
base_time = datetime.datetime(2024, 3, 15, 10, 0, 0)

services = ["api-gateway", "auth-service", "order-service", "payment-service", "database", "cache"]
event_types = ["error", "warning", "latency_spike", "connection_refused", "timeout", "crash", "oom"]

events = []
event_id = 1

# 4 incident clusters, each 10-15 events within 60s windows
cluster_starts = [0, 600, 1800, 3600]  # seconds from base
for ci, start_offset in enumerate(cluster_starts):
    cluster_size = random.randint(10, 15)
    cluster_services = random.sample(services, k=random.randint(3, 5))
    cluster_start = base_time + datetime.timedelta(seconds=start_offset)
    for j in range(cluster_size):
        ts = cluster_start + datetime.timedelta(seconds=random.randint(0, 60))
        svc = random.choice(cluster_services)
        etype = random.choice(event_types)
        events.append({
            "event_id": f"evt-{event_id:04d}",
            "timestamp": ts.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "service": svc,
            "event_type": etype,
            "message": f"{etype.replace('_', ' ').title()} on {svc}",
            "severity": random.choice(["warning", "critical"]) if etype in ("crash", "oom", "connection_refused") else "warning",
            "metadata": {
                "host": f"{svc}-{random.randint(1,3)}.internal",
                "region": random.choice(["us-east-1", "us-west-2"]),
                "duration_ms": random.randint(100, 30000) if "latency" in etype or "timeout" in etype else None
            }
        })
        event_id += 1

# 15 noise events scattered between clusters
for _ in range(15):
    offset = random.randint(60, 4200)
    ts = base_time + datetime.timedelta(seconds=offset)
    svc = random.choice(services)
    etype = random.choice(["warning", "info"])
    events.append({
        "event_id": f"evt-{event_id:04d}",
        "timestamp": ts.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "service": svc,
        "event_type": etype,
        "message": f"Routine {etype} on {svc}",
        "severity": "info",
        "metadata": {
            "host": f"{svc}-{random.randint(1,3)}.internal",
            "region": random.choice(["us-east-1", "us-west-2"]),
            "duration_ms": None
        }
    })
    event_id += 1

# Trim to exactly 85
events = events[:85]
while len(events) < 85:
    ts = base_time + datetime.timedelta(seconds=random.randint(0, 4200))
    svc = random.choice(services)
    events.append({
        "event_id": f"evt-{event_id:04d}",
        "timestamp": ts.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "service": svc,
        "event_type": "info",
        "message": f"Routine check on {svc}",
        "severity": "info",
        "metadata": {"host": f"{svc}-1.internal", "region": "us-east-1", "duration_ms": None}
    })
    event_id += 1

events.sort(key=lambda e: e["timestamp"])
with open("/home/runner/events.json", "w") as f:
    json.dump(events, f, indent=2)
print(f"Generated {len(events)} events (4 clusters + noise) to ~/events.json")
