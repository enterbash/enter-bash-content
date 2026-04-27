#!/usr/bin/env python3
"""Generate 52 raw alerts from a cascading DB failure scenario."""
import json, random, datetime

random.seed(42)
base_time = datetime.datetime(2024, 3, 15, 14, 30, 0)
alerts = []

services = ["database", "api-gateway", "auth-service", "order-service", "payment-service"]
alert_types = {
    "database": ["DatabaseDown", "DatabaseSlow", "DiskSpaceLow"],
    "api-gateway": ["HighLatency", "ErrorRateHigh", "TimeoutError", "HealthCheckFailed"],
    "auth-service": ["ConnectionPoolExhausted", "HighLatency", "ErrorRateHigh", "HealthCheckFailed"],
    "order-service": ["ConnectionPoolExhausted", "HighLatency", "ErrorRateHigh", "TimeoutError"],
    "payment-service": ["ConnectionPoolExhausted", "HighLatency", "ErrorRateHigh", "HealthCheckFailed"],
}
severities = {"DatabaseDown": "critical", "DatabaseSlow": "warning", "DiskSpaceLow": "warning",
              "ConnectionPoolExhausted": "critical", "HighLatency": "warning",
              "ErrorRateHigh": "critical", "HealthCheckFailed": "warning", "TimeoutError": "warning"}

# Root cause: database goes down at t=0
# Cascade: DB alerts first, then dependent services within 30-120s
cascade_order = [
    ("database", "DatabaseDown", 0),
    ("database", "DatabaseSlow", 2),
    ("database", "DiskSpaceLow", 5),
    ("api-gateway", "HighLatency", 15),
    ("auth-service", "ConnectionPoolExhausted", 20),
    ("order-service", "ConnectionPoolExhausted", 22),
    ("payment-service", "ConnectionPoolExhausted", 25),
    ("api-gateway", "ErrorRateHigh", 30),
    ("auth-service", "HighLatency", 32),
    ("order-service", "HighLatency", 35),
    ("payment-service", "HighLatency", 38),
    ("api-gateway", "TimeoutError", 45),
    ("order-service", "TimeoutError", 48),
    ("auth-service", "ErrorRateHigh", 50),
    ("order-service", "ErrorRateHigh", 55),
    ("payment-service", "ErrorRateHigh", 58),
    ("api-gateway", "HealthCheckFailed", 65),
    ("auth-service", "HealthCheckFailed", 68),
    ("payment-service", "HealthCheckFailed", 72),
]

alert_id = 1
for svc, atype, offset_s in cascade_order:
    ts = base_time + datetime.timedelta(seconds=offset_s + random.randint(0, 3))
    # Generate 2-4 duplicate alerts per event (monitoring fires repeatedly)
    dupes = random.randint(2, 4)
    for d in range(dupes):
        fire_ts = ts + datetime.timedelta(seconds=d * random.randint(5, 15))
        alerts.append({
            "alert_id": f"alert-{alert_id:04d}",
            "timestamp": fire_ts.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "service": svc,
            "alert_name": atype,
            "severity": severities[atype],
            "instance": f"{svc}-{random.randint(1,3)}",
            "message": f"{atype} on {svc}: threshold exceeded",
            "fingerprint": f"{svc}:{atype}",
            "status": "firing"
        })
        alert_id += 1

# Trim or pad to exactly 52
alerts = alerts[:52] if len(alerts) > 52 else alerts
while len(alerts) < 52:
    svc = random.choice(services)
    atype = random.choice(alert_types[svc])
    ts = base_time + datetime.timedelta(seconds=random.randint(0, 120))
    alerts.append({
        "alert_id": f"alert-{alert_id:04d}",
        "timestamp": ts.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "service": svc,
        "alert_name": atype,
        "severity": severities[atype],
        "instance": f"{svc}-{random.randint(1,3)}",
        "message": f"{atype} on {svc}: threshold exceeded",
        "fingerprint": f"{svc}:{atype}",
        "status": "firing"
    })
    alert_id += 1

alerts.sort(key=lambda a: a["timestamp"])
with open("/home/runner/raw_alerts.json", "w") as f:
    json.dump(alerts, f, indent=2)
print(f"Generated {len(alerts)} alerts to ~/raw_alerts.json")
