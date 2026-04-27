#!/usr/bin/env python3
"""Mock OpenAI-compatible LLM server for AIOps challenges.
Runs Flask on port 8080, returns realistic mock responses based on prompt content.
"""
import json, re, os, sys
from http.server import HTTPServer, BaseHTTPRequestHandler
import threading

class MockLLMHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # Suppress request logs

    def do_POST(self):
        if self.path == "/v1/chat/completions":
            content_length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(content_length)
            try:
                data = json.loads(body)
            except json.JSONDecodeError:
                self.send_error(400, "Invalid JSON")
                return

            messages = data.get("messages", [])
            prompt = " ".join(m.get("content", "") for m in messages).lower()
            response_text = self._generate_response(prompt)

            result = {
                "id": "chatcmpl-mock-001",
                "object": "chat.completion",
                "model": "mock-llm-v1",
                "choices": [{
                    "index": 0,
                    "message": {"role": "assistant", "content": response_text},
                    "finish_reason": "stop"
                }],
                "usage": {"prompt_tokens": len(prompt.split()), "completion_tokens": len(response_text.split()), "total_tokens": len(prompt.split()) + len(response_text.split())}
            }
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(result).encode())
        else:
            self.send_error(404, "Not found")

    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok"}).encode())
        else:
            self.send_error(404, "Not found")

    def _generate_response(self, prompt):
        # Log summarization
        if re.search(r"(summarize|summary|log|error.*count|root.?cause)", prompt):
            if re.search(r"(connection.?pool|database|db)", prompt):
                return json.dumps({
                    "summary": "Database connection pool exhaustion causing cascading failures across services.",
                    "error_count": 47,
                    "key_events": [
                        "Connection pool reached max capacity at 14:32:15",
                        "Auth service began returning 503 errors at 14:32:30",
                        "Order processing queue backed up at 14:33:00",
                        "Automated failover triggered at 14:35:00"
                    ],
                    "likely_root_cause": "Database connection pool exhaustion due to long-running queries from the reporting service",
                    "severity": "critical",
                    "affected_services": ["database", "auth-service", "order-service", "api-gateway"]
                })
            return json.dumps({
                "summary": "Multiple service errors detected with elevated latency.",
                "error_count": 23,
                "key_events": [
                    "Error rate spike detected at 10:15:00",
                    "Latency increased 3x baseline at 10:15:30",
                    "Health checks failing at 10:16:00"
                ],
                "likely_root_cause": "Upstream dependency timeout causing cascading failures",
                "severity": "warning",
                "affected_services": ["api-gateway", "order-service"]
            })

        # PromQL generation
        if re.search(r"(promql|prometheus|query|metric|rate|histogram)", prompt):
            return json.dumps({
                "generated_promql": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) by (service) / sum(rate(http_requests_total[5m])) by (service)",
                "explanation": "Calculates the 5xx error rate per service over a 5-minute window",
                "alternatives": [
                    "histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service))",
                    "sum by (service) (increase(http_requests_total{status=~\"5..\"}[1h]))",
                    "avg_over_time(up{job=\"api-gateway\"}[5m])"
                ]
            })

        # Incident diagnosis / copilot
        if re.search(r"(incident|diagnos|investig|tool|action|remediat)", prompt):
            return json.dumps({
                "diagnosis": "The incident appears to be caused by a memory leak in the order-service following deployment v2.14.3. The service's memory usage grew linearly until OOM-killed, causing cascading timeouts.",
                "confidence": 0.85,
                "evidence": [
                    "Memory usage grew from 512MB to 3.8GB over 2 hours",
                    "Deployment v2.14.3 was rolled out 2 hours before incident",
                    "No similar pattern before the deployment",
                    "OOM kill events in kernel logs"
                ],
                "recommended_actions": [
                    "Rollback order-service to v2.14.2",
                    "Increase memory limits temporarily",
                    "Add memory usage alerting at 80% threshold",
                    "Review PR #1847 for memory leak in connection handling"
                ],
                "tools_used": ["query_prometheus", "search_logs", "get_deployments"]
            })

        # Chaos / anomaly detection
        if re.search(r"(chaos|stress|cpu|memory|anomal|detect)", prompt):
            return json.dumps({
                "analysis": "Detected anomalous CPU and memory patterns consistent with stress testing or resource exhaustion.",
                "anomalies": [
                    {"metric": "cpu_usage", "value": 98.5, "threshold": 80, "timestamp": "2024-03-15T14:35:00Z"},
                    {"metric": "memory_usage", "value": 95.2, "threshold": 85, "timestamp": "2024-03-15T14:35:00Z"}
                ],
                "probable_cause": "Artificial stress injection or runaway process consuming CPU and memory resources"
            })

        # Default fallback
        return json.dumps({
            "response": "Based on the provided data, the system shows signs of degraded performance. Further investigation recommended.",
            "confidence": 0.6
        })

def main():
    port = int(os.environ.get("MOCK_LLM_PORT", 8080))
    server = HTTPServer(("0.0.0.0", port), MockLLMHandler)
    print(f"Mock LLM server running on port {port}")
    sys.stdout.flush()
    server.serve_forever()

if __name__ == "__main__":
    main()
