#!/usr/bin/env python3
"""Sends sample OTLP telemetry to the OTel Collector via HTTP."""

import json
import time
import random
import urllib.request

OTEL_HTTP = "http://localhost:4318"

def send_metrics():
    """Send a simple metric via OTLP HTTP."""
    payload = {
        "resourceMetrics": [{
            "resource": {
                "attributes": [
                    {"key": "service.name", "value": {"stringValue": "test-service"}}
                ]
            },
            "scopeMetrics": [{
                "scope": {"name": "test"},
                "metrics": [{
                    "name": "http_requests_total",
                    "sum": {
                        "dataPoints": [{
                            "asInt": str(random.randint(100, 1000)),
                            "startTimeUnixNano": str(int((time.time() - 60) * 1e9)),
                            "timeUnixNano": str(int(time.time() * 1e9)),
                            "attributes": [
                                {"key": "method", "value": {"stringValue": "GET"}},
                                {"key": "status", "value": {"stringValue": "200"}}
                            ]
                        }],
                        "aggregationTemporality": 2,
                        "isMonotonic": True
                    }
                }]
            }]
        }]
    }

    data = json.dumps(payload).encode()
    req = urllib.request.Request(
        f"{OTEL_HTTP}/v1/metrics",
        data=data,
        headers={"Content-Type": "application/json"}
    )
    try:
        resp = urllib.request.urlopen(req, timeout=5)
        print(f"Metrics sent: {resp.status}")
    except Exception as e:
        print(f"Failed to send metrics: {e}")

def send_traces():
    """Send a simple trace via OTLP HTTP."""
    trace_id = format(random.getrandbits(128), '032x')
    span_id = format(random.getrandbits(64), '016x')
    now_ns = str(int(time.time() * 1e9))
    start_ns = str(int((time.time() - 0.1) * 1e9))

    payload = {
        "resourceSpans": [{
            "resource": {
                "attributes": [
                    {"key": "service.name", "value": {"stringValue": "test-service"}}
                ]
            },
            "scopeSpans": [{
                "scope": {"name": "test"},
                "spans": [{
                    "traceId": trace_id,
                    "spanId": span_id,
                    "name": "GET /api/test",
                    "kind": 2,
                    "startTimeUnixNano": start_ns,
                    "endTimeUnixNano": now_ns,
                    "status": {"code": 1}
                }]
            }]
        }]
    }

    data = json.dumps(payload).encode()
    req = urllib.request.Request(
        f"{OTEL_HTTP}/v1/traces",
        data=data,
        headers={"Content-Type": "application/json"}
    )
    try:
        resp = urllib.request.urlopen(req, timeout=5)
        print(f"Trace sent: {resp.status}")
    except Exception as e:
        print(f"Failed to send trace: {e}")

if __name__ == "__main__":
    print("Sending test telemetry to OTel Collector...")
    for i in range(5):
        send_metrics()
        send_traces()
        time.sleep(0.5)
    print("Done! Check collector logs and prometheus endpoint.")
