#!/usr/bin/env python3
"""Generate messy application logs with various error types."""
import random, datetime

random.seed(42)
base = datetime.datetime(2024, 1, 15, 0, 0, 0)
hosts = ["db-primary.internal", "db-replica.internal", "cache-01.internal", "api-gateway.internal"]
ports = [5432, 6379, 8080, 3306, 443]
users = [f"user_{i}" for i in range(20)]
queries = ["SELECT * FROM users WHERE id=", "INSERT INTO orders VALUES", "UPDATE sessions SET", "DELETE FROM temp_"]

error_templates = [
    ("ERROR", "Connection refused to {host}:{port} — retrying in 5s"),
    ("ERROR", "Connection reset by peer: {host}:{port}"),
    ("ERROR", "Connection timeout after 30s to {host}:{port}"),
    ("ERROR", "Request timed out after {dur}ms for /api/{ep}"),
    ("ERROR", "Timeout exceeded: {dur}ms waiting for response from {host}"),
    ("ERROR", "Database error: query failed — {query}{qid}"),
    ("ERROR", "SQL syntax error near '{query}{qid}'"),
    ("ERROR", "Database connection pool exhausted (max: 50)"),
    ("ERROR", "Authentication failed for user '{user}' from {ip}"),
    ("ERROR", "Unauthorized access attempt to /admin/{ep} by {user}"),
    ("ERROR", "Permission denied: {user} cannot access resource /data/{qid}"),
    ("ERROR", "Null pointer exception in RequestHandler.process()"),
    ("ERROR", "OutOfMemoryError: heap space exhausted"),
    ("ERROR", "File not found: /var/data/cache/{qid}.tmp"),
]

info_templates = [
    ("INFO", "Request completed: GET /api/{ep} 200 ({dur}ms)"),
    ("INFO", "Request completed: POST /api/{ep} 201 ({dur}ms)"),
    ("INFO", "User {user} logged in from {ip}"),
    ("INFO", "Cache hit for key session:{qid}"),
    ("INFO", "Health check passed: all services healthy"),
    ("WARNING", "High latency detected: {dur}ms for /api/{ep}"),
    ("WARNING", "Memory usage at 85% — consider scaling"),
    ("WARNING", "Slow query detected: {query}{qid} took {dur}ms"),
]

lines = []
for i in range(500):
    ts = base + datetime.timedelta(seconds=i * 3 + random.randint(0, 2))
    ts_str = ts.strftime("%Y-%m-%d %H:%M:%S")
    if random.random() < 0.35:
        tmpl = random.choice(error_templates)
    else:
        tmpl = random.choice(info_templates)
    level, msg = tmpl
    msg = msg.format(
        host=random.choice(hosts), port=random.choice(ports),
        dur=random.randint(50, 5000), ep=random.choice(["users", "orders", "products", "search", "auth"]),
        user=random.choice(users), ip=f"10.0.{random.randint(1,10)}.{random.randint(1,254)}",
        query=random.choice(queries), qid=random.randint(1000, 9999)
    )
    lines.append(f"{ts_str} [{level}] {msg}")

with open("/home/runner/application.log", "w") as f:
    f.write("\n".join(lines) + "\n")
print(f"Generated {len(lines)} log lines to ~/application.log")
