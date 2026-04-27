#!/bin/bash
set -e
python3 ~/mock_llm_server.py &
sleep 1

# Create sample incident description
cat > ~/incident.txt << 'INCIDENT'
Incident INC-2847: Order Service Outage
Severity: Critical
Started: 2024-03-15T14:32:00Z
Duration: ~6 minutes

Summary:
The order-service became unresponsive at 14:32 UTC, causing cascading failures
across api-gateway, auth-service, and payment-service. Users reported 503 errors
on all order-related endpoints. The api-gateway health check began failing at 14:33.

Timeline:
- 14:30: Normal operations, all services healthy
- 14:32: order-service stops responding to health checks
- 14:32:15: api-gateway starts returning 503 for /api/v1/orders
- 14:32:30: auth-service reports connection errors to order-service
- 14:33:00: api-gateway health check fails (4/5 services unhealthy)
- 14:34:00: On-call engineer paged
- 14:35:00: order-service pod restarted automatically by kubelet
- 14:36:00: Services recovering, circuit breakers closing
- 14:38:00: All services healthy, incident resolved

Impact:
- ~200 failed order requests
- ~350 failed auth requests
- Revenue impact estimated at $12,000

Recent changes:
- order-service v2.14.3 deployed at 12:15 UTC (2h before incident)
- auth-service v1.8.1 deployed at 10:30 UTC
INCIDENT

if curl -s http://localhost:8080/health | grep -q "ok"; then
  echo "Ready: Mock LLM server on port 8080, incident at ~/incident.txt, tools at ~/mock_tools.py."
else
  echo "Warning: Mock LLM server may not have started. Try: python3 ~/mock_llm_server.py &"
fi
