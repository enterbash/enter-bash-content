#!/usr/bin/env python3
"""Mock OpenAI-compatible LLM server for AIOps challenges.
Runs on port 8080, returns realistic mock responses based on prompt content.
"""
import json, re, os, sys
from http.server import HTTPServer, BaseHTTPRequestHandler

class MockLLMHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

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
                "choices": [{"index": 0, "message": {"role": "assistant", "content": response_text}, "finish_reason": "stop"}],
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
        if re.search(r"(promql|prometheus|query|metric|rate|histogram|error.rate)", prompt):
            return json.dumps({
                "generated_promql": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) by (service) / sum(rate(http_requests_total[5m])) by (service)",
                "explanation": "Calculates the 5xx error rate per service over a 5-minute window",
                "alternatives": [
                    "histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service))",
                    "sum by (service) (increase(http_requests_total{status=~\"5..\"}[1h]))",
                    "avg_over_time(up{job=\"api-gateway\"}[5m])"
                ]
            })
        if re.search(r"(latency|p99|percentile|slow)", prompt):
            return json.dumps({
                "generated_promql": "histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))",
                "explanation": "Calculates the p99 latency across all services over a 5-minute window"
            })
        if re.search(r"(cpu|memory|resource|utilization)", prompt):
            return json.dumps({
                "generated_promql": "100 - (avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
                "explanation": "Calculates CPU utilization percentage per instance"
            })
        if re.search(r"(disk|storage|volume)", prompt):
            return json.dumps({
                "generated_promql": "(node_filesystem_size_bytes - node_filesystem_avail_bytes) / node_filesystem_size_bytes * 100",
                "explanation": "Calculates disk usage percentage per filesystem"
            })
        if re.search(r"(availability|uptime|up)", prompt):
            return json.dumps({
                "generated_promql": "avg_over_time(up[1h])",
                "explanation": "Calculates service availability over the last hour"
            })
        return json.dumps({
            "generated_promql": "sum(rate(http_requests_total[5m])) by (service)",
            "explanation": "Calculates request rate per service over 5 minutes"
        })

def main():
    port = int(os.environ.get("MOCK_LLM_PORT", 8080))
    server = HTTPServer(("0.0.0.0", port), MockLLMHandler)
    print(f"Mock LLM server running on port {port}")
    sys.stdout.flush()
    server.serve_forever()

if __name__ == "__main__":
    main()
