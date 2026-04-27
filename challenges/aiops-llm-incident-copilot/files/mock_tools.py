#!/usr/bin/env python3
"""Mock tool functions for the incident copilot challenge.
These simulate real observability tool calls returning mock data.
"""
import json, datetime

def query_prometheus(query="", duration="1h"):
    """Simulate a Prometheus query returning metric data."""
    base_time = datetime.datetime(2024, 3, 15, 14, 30, 0)
    if "error" in query or "5.." in query or "status" in query:
        return {
            "status": "success",
            "data": {
                "resultType": "vector",
                "result": [
                    {"metric": {"service": "order-service"}, "value": [base_time.timestamp(), "0.15"]},
                    {"metric": {"service": "api-gateway"}, "value": [base_time.timestamp(), "0.12"]},
                    {"metric": {"service": "auth-service"}, "value": [base_time.timestamp(), "0.08"]},
                    {"metric": {"service": "payment-service"}, "value": [base_time.timestamp(), "0.03"]},
                ]
            }
        }
    if "memory" in query or "container_memory" in query:
        return {
            "status": "success",
            "data": {
                "resultType": "matrix",
                "result": [
                    {"metric": {"pod": "order-service-7b4d9f-x2k1"},
                     "values": [
                         [base_time.timestamp() - 7200, "536870912"],
                         [base_time.timestamp() - 3600, "1610612736"],
                         [base_time.timestamp() - 1800, "2684354560"],
                         [base_time.timestamp(), "3865470566"],
                     ]}
                ]
            }
        }
    if "cpu" in query:
        return {
            "status": "success",
            "data": {
                "resultType": "vector",
                "result": [
                    {"metric": {"instance": "node-1"}, "value": [base_time.timestamp(), "0.45"]},
                    {"metric": {"instance": "node-2"}, "value": [base_time.timestamp(), "0.92"]},
                ]
            }
        }
    return {"status": "success", "data": {"resultType": "vector", "result": []}}


def search_logs(service="", severity="error", since="1h"):
    """Simulate searching application logs."""
    logs = []
    if "order" in service.lower():
        logs = [
            {"timestamp": "2024-03-15T14:30:15Z", "level": "ERROR", "message": "OutOfMemoryError: Java heap space", "service": "order-service"},
            {"timestamp": "2024-03-15T14:31:00Z", "level": "ERROR", "message": "GC overhead limit exceeded", "service": "order-service"},
            {"timestamp": "2024-03-15T14:32:00Z", "level": "FATAL", "message": "Container killed by OOM: memory limit 2Gi exceeded", "service": "order-service"},
            {"timestamp": "2024-03-15T14:32:05Z", "level": "ERROR", "message": "Connection reset by peer: order-service-7b4d9f-x2k1", "service": "api-gateway"},
            {"timestamp": "2024-03-15T14:32:10Z", "level": "ERROR", "message": "Upstream timeout: order-service not responding", "service": "api-gateway"},
        ]
    elif "auth" in service.lower():
        logs = [
            {"timestamp": "2024-03-15T14:32:30Z", "level": "ERROR", "message": "Connection refused to order-service", "service": "auth-service"},
            {"timestamp": "2024-03-15T14:32:45Z", "level": "WARN", "message": "Fallback: using cached auth tokens", "service": "auth-service"},
        ]
    else:
        logs = [
            {"timestamp": "2024-03-15T14:32:00Z", "level": "ERROR", "message": "OOM kill event for order-service pod", "service": "kubelet"},
            {"timestamp": "2024-03-15T14:32:05Z", "level": "WARN", "message": "Pod order-service-7b4d9f-x2k1 restarting", "service": "kubelet"},
            {"timestamp": "2024-03-15T14:32:30Z", "level": "ERROR", "message": "Multiple 503 responses from upstream", "service": "api-gateway"},
        ]
    return {"total": len(logs), "logs": logs}


def get_deployments(service="", since="24h"):
    """Simulate fetching recent deployment history."""
    deployments = [
        {"deploy_id": "deploy-091", "timestamp": "2024-03-15T12:15:00Z", "service": "order-service",
         "version": "v2.14.3", "author": "dev-3", "changed_files": 12,
         "commit_message": "Refactor connection pooling and add request buffering",
         "rollback_available": True},
        {"deploy_id": "deploy-090", "timestamp": "2024-03-15T10:30:00Z", "service": "auth-service",
         "version": "v1.8.1", "author": "dev-5", "changed_files": 3,
         "commit_message": "Update token expiry configuration",
         "rollback_available": True},
        {"deploy_id": "deploy-089", "timestamp": "2024-03-14T16:00:00Z", "service": "order-service",
         "version": "v2.14.2", "author": "dev-3", "changed_files": 5,
         "commit_message": "Fix pagination in order listing",
         "rollback_available": True},
        {"deploy_id": "deploy-088", "timestamp": "2024-03-14T11:00:00Z", "service": "api-gateway",
         "version": "v3.2.0", "author": "dev-1", "changed_files": 8,
         "commit_message": "Add rate limiting middleware",
         "rollback_available": True},
    ]
    if service:
        deployments = [d for d in deployments if d["service"] == service]
    return {"total": len(deployments), "deployments": deployments}
