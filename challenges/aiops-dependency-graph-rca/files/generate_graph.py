#!/usr/bin/env python3
"""Generate service dependency graph and failing services for RCA."""
import json, random

random.seed(42)

# 12-service dependency graph
graph = {
    "services": [
        {"name": "api-gateway", "depends_on": ["auth-service", "order-service", "user-service"]},
        {"name": "auth-service", "depends_on": ["database-primary", "cache-redis"]},
        {"name": "order-service", "depends_on": ["payment-service", "database-primary", "inventory-service"]},
        {"name": "payment-service", "depends_on": ["database-primary", "external-payment-api"]},
        {"name": "user-service", "depends_on": ["database-primary", "cache-redis"]},
        {"name": "inventory-service", "depends_on": ["database-primary"]},
        {"name": "notification-service", "depends_on": ["queue-rabbitmq", "email-service"]},
        {"name": "email-service", "depends_on": []},
        {"name": "database-primary", "depends_on": ["storage-volume"]},
        {"name": "cache-redis", "depends_on": []},
        {"name": "queue-rabbitmq", "depends_on": []},
        {"name": "storage-volume", "depends_on": []},
        {"name": "external-payment-api", "depends_on": []}
    ]
}

with open("/home/runner/service_graph.json", "w") as f:
    json.dump(graph, f, indent=2)

# Failing services: database-primary is root cause, cascading up
failing = [
    {"service": "database-primary", "status": "down", "error": "Connection refused on port 5432", "since": "2024-03-15T14:30:00Z"},
    {"service": "auth-service", "status": "degraded", "error": "Cannot connect to database-primary", "since": "2024-03-15T14:30:15Z"},
    {"service": "order-service", "status": "degraded", "error": "Database queries timing out", "since": "2024-03-15T14:30:20Z"},
    {"service": "payment-service", "status": "degraded", "error": "Failed to persist transaction", "since": "2024-03-15T14:30:25Z"},
    {"service": "api-gateway", "status": "degraded", "error": "Upstream services returning 503", "since": "2024-03-15T14:30:30Z"}
]

with open("/home/runner/failing_services.json", "w") as f:
    json.dump(failing, f, indent=2)

print(f"Generated service_graph.json (12 services) and failing_services.json (5 failing)")
