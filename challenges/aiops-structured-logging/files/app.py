#!/usr/bin/env python3
"""Simple web API simulator with UNSTRUCTURED logging.
Your task: convert this to output JSON structured logs."""

import time
import random

ENDPOINTS = ["/api/users", "/api/orders", "/api/products", "/api/health", "/api/search"]
LEVELS = ["INFO", "INFO", "INFO", "WARNING", "ERROR"]

def log(level, message):
    ts = time.strftime("%Y-%m-%d %H:%M:%S")
    print(f"{ts} - {level} - {message}")

def simulate_requests():
    for i in range(20):
        endpoint = random.choice(ENDPOINTS)
        latency = random.randint(5, 500)
        status = random.choice([200, 200, 200, 200, 201, 400, 404, 500])
        level = "INFO"
        if status >= 500:
            level = "ERROR"
        elif status >= 400 or latency > 300:
            level = "WARNING"

        if level == "ERROR":
            log(level, f"Request failed: {endpoint} returned {status}")
        elif latency > 300:
            log(level, f"High latency detected: {latency}ms for {endpoint}")
        else:
            log(level, f"Request OK: {endpoint} {status} ({latency}ms)")

        time.sleep(0.05)

if __name__ == "__main__":
    log("INFO", "web-api service starting")
    simulate_requests()
    log("INFO", "web-api service shutting down")
