#!/usr/bin/env python3
"""Generate deployment and incident data for correlation analysis."""
import json, random, datetime

random.seed(42)
base_time = datetime.datetime(2024, 3, 15, 0, 0, 0)

services = ["api-gateway", "auth-service", "order-service", "payment-service",
            "user-service", "notification-service", "inventory-service"]
deploy_types = ["rolling", "blue-green", "canary"]

# 15 deployments over 24h
deployments = []
for i in range(15):
    offset_min = random.randint(0, 1380)
    ts = base_time + datetime.timedelta(minutes=offset_min)
    svc = random.choice(services)
    deployments.append({
        "deploy_id": f"deploy-{i+1:03d}",
        "timestamp": ts.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "service": svc,
        "version": f"v{random.randint(1,5)}.{random.randint(0,20)}.{random.randint(0,99)}",
        "deploy_type": random.choice(deploy_types),
        "changed_files": random.randint(1, 45),
        "author": f"dev-{random.randint(1,8)}"
    })

deployments.sort(key=lambda d: d["timestamp"])

# 8 incidents, 6 correlated with deployments (within 30 min after deploy)
incidents = []
correlated_deploys = random.sample(range(len(deployments)), 6)
for idx, di in enumerate(correlated_deploys):
    dep = deployments[di]
    dep_ts = datetime.datetime.strptime(dep["timestamp"], "%Y-%m-%dT%H:%M:%SZ")
    inc_ts = dep_ts + datetime.timedelta(minutes=random.randint(3, 30))
    incidents.append({
        "incident_id": f"inc-{idx+1:03d}",
        "timestamp": inc_ts.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "service": dep["service"],
        "severity": random.choice(["warning", "critical"]),
        "description": f"Elevated error rate on {dep['service']} after deployment",
        "duration_minutes": random.randint(5, 120),
        "resolved": True
    })

# 2 uncorrelated incidents
for idx in range(6, 8):
    offset_min = random.randint(0, 1380)
    ts = base_time + datetime.timedelta(minutes=offset_min)
    svc = random.choice(services)
    incidents.append({
        "incident_id": f"inc-{idx+1:03d}",
        "timestamp": ts.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "service": svc,
        "severity": random.choice(["warning", "critical"]),
        "description": f"Intermittent connectivity issue on {svc}",
        "duration_minutes": random.randint(5, 60),
        "resolved": True
    })

incidents.sort(key=lambda i: i["timestamp"])

with open("/home/runner/deployments.json", "w") as f:
    json.dump(deployments, f, indent=2)
with open("/home/runner/incidents.json", "w") as f:
    json.dump(incidents, f, indent=2)

print(f"Generated deployments.json ({len(deployments)}) and incidents.json ({len(incidents)}, 6 correlated)")
