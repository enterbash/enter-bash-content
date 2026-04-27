#!/usr/bin/env python3
"""Generate varied log lines for clustering exercise."""
import random

random.seed(42)
templates = [
    ("Connection from {ip} to port {port} established", 120),
    ("Request {rid} completed in {dur}ms with status {status}", 100),
    ("User {user} authenticated via {method}", 80),
    ("Cache miss for key {key} — fetching from database", 70),
    ("Query executed in {dur}ms: SELECT * FROM {table} WHERE id = {id}", 60),
    ("Health check from {ip}: all services responding", 50),
    ("File uploaded: {file} ({size}KB) by user {user}", 45),
    ("Rate limit exceeded for {ip}: {count} requests in {dur}s", 40),
    ("SSL handshake completed with {ip} using TLS {ver}", 35),
    ("Deployment {rid} started for service {svc}", 30),
    ("Memory usage at {pct}% on node {node}", 80),
    ("Disk I/O latency {dur}ms on volume {vol}", 60),
    ("DNS resolution for {host} took {dur}ms", 50),
    ("Garbage collection pause: {dur}ms (heap: {size}MB)", 40),
    ("Background job {rid} completed in {dur}s", 40),
]

ips = [f"10.0.{random.randint(1,10)}.{random.randint(1,254)}" for _ in range(30)]
users = [f"user_{i}" for i in range(20)]
services = ["api-gateway", "auth-service", "order-service", "payment-service", "notification-service"]
tables = ["users", "orders", "products", "sessions", "events"]

lines = []
for tmpl, count in templates:
    for _ in range(count):
        line = tmpl.format(
            ip=random.choice(ips), port=random.choice([80, 443, 8080, 3000, 5432, 6379]),
            rid=f"req-{random.randint(10000,99999)}", dur=random.randint(1, 5000),
            status=random.choice([200, 201, 204, 301, 400, 404, 500]),
            user=random.choice(users), method=random.choice(["password", "oauth", "sso", "api_key"]),
            key=f"session:{random.randint(1000,9999)}", table=random.choice(tables),
            id=random.randint(1, 100000), file=f"upload_{random.randint(1,999)}.csv",
            size=random.randint(10, 5000), count=random.randint(100, 1000),
            ver=random.choice(["1.2", "1.3"]), svc=random.choice(services),
            pct=random.randint(40, 95), node=f"node-{random.randint(1,5)}",
            vol=f"/dev/sd{random.choice('abcd')}", host=f"{random.choice(services)}.internal",
        )
        lines.append(line)

random.shuffle(lines)
with open("/home/runner/varied.log", "w") as f:
    f.write("\n".join(lines) + "\n")
print(f"Generated {len(lines)} log lines to ~/varied.log")
