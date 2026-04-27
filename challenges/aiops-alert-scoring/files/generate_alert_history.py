#!/usr/bin/env python3
"""Generate alert history (500 rows) and new alerts (50 rows) for scoring."""
import csv, random

random.seed(42)

services = ["api-gateway", "auth-service", "order-service", "payment-service", "database", "cache"]
alert_types = ["HighLatency", "ErrorRateHigh", "DiskSpaceLow", "MemoryHigh", "CPUHigh",
               "HealthCheckFailed", "ConnectionPoolExhausted", "TimeoutError"]

def make_alert(include_actionable=True):
    hour = random.randint(0, 23)
    service = random.choice(services)
    atype = random.choice(alert_types)
    duration = random.randint(30, 7200)
    co_occurring = random.randint(0, 8)
    # Actionable heuristic: critical types during business hours with long duration are more actionable
    if include_actionable:
        score = 0
        if atype in ("ErrorRateHigh", "ConnectionPoolExhausted", "HealthCheckFailed"):
            score += 2
        if 9 <= hour <= 17:
            score += 1
        if duration > 600:
            score += 1
        if co_occurring > 3:
            score += 1
        actionable = 1 if (score >= 3 or random.random() < 0.15) else 0
        if score <= 1 and random.random() < 0.7:
            actionable = 0
        return {"hour": hour, "service": service, "alert_type": atype,
                "duration_seconds": duration, "co_occurring_alerts": co_occurring,
                "actionable": actionable}
    else:
        return {"hour": hour, "service": service, "alert_type": atype,
                "duration_seconds": duration, "co_occurring_alerts": co_occurring}

# History: 500 rows with actionable label
history = [make_alert(True) for _ in range(500)]
with open("/home/runner/alert_history.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["hour", "service", "alert_type", "duration_seconds",
                                       "co_occurring_alerts", "actionable"])
    w.writeheader()
    w.writerows(history)

# New alerts: 50 rows without actionable
new_alerts = [make_alert(False) for _ in range(50)]
with open("/home/runner/new_alerts.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["hour", "service", "alert_type", "duration_seconds",
                                       "co_occurring_alerts"])
    w.writeheader()
    w.writerows(new_alerts)

print(f"Generated alert_history.csv (500 rows) and new_alerts.csv (50 rows)")
