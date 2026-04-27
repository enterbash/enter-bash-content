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
        # Tool-calling / incident copilot responses
        if re.search(r"(tool|function|call|query_prometheus|search_logs|get_deploy)", prompt):
            return json.dumps({
                "action": "call_tool",
                "tool": "query_prometheus",
                "arguments": {"query": "rate(http_requests_total{status=~'5..'}[5m])", "duration": "1h"},
                "reasoning": "Need to check error rates to understand the scope of the incident"
            })
        if re.search(r"(incident|diagnos|investig|analyz|root.?cause)", prompt):
            return json.dumps({
                "diagnosis": "The incident is caused by a memory leak in order-service following deployment v2.14.3. Memory usage grew linearly until OOM-killed, causing cascading timeouts across dependent services.",
                "confidence": 0.85,
                "evidence": [
                    "Memory usage grew from 512MB to 3.8GB over 2 hours",
                    "Deployment v2.14.3 rolled out 2 hours before incident",
                    "No similar pattern before the deployment",
                    "OOM kill events in kernel logs at 14:32:00"
                ],
                "recommended_actions": [
                    "Rollback order-service to v2.14.2",
                    "Increase memory limits temporarily to 4Gi",
                    "Add memory usage alerting at 80% threshold",
                    "Review PR #1847 for memory leak in connection handling"
                ],
                "tools_used": ["query_prometheus", "search_logs", "get_deployments"]
            })
        if re.search(r"(summarize|summary|log|error)", prompt):
            return json.dumps({
                "summary": "Cascading failure originating from order-service OOM. 3 services affected.",
                "error_count": 47,
                "key_events": ["OOM kill at 14:32", "Circuit breakers opened at 14:33", "Recovery at 14:38"],
                "likely_root_cause": "Memory leak in order-service v2.14.3"
            })
        return json.dumps({
            "response": "Based on the available data, further investigation is needed. I recommend checking recent deployments and resource utilization metrics.",
            "confidence": 0.5,
            "next_steps": ["Check deployment history", "Review resource metrics", "Search application logs"]
        })

def main():
    port = int(os.environ.get("MOCK_LLM_PORT", 8080))
    server = HTTPServer(("0.0.0.0", port), MockLLMHandler)
    print(f"Mock LLM server running on port {port}")
    sys.stdout.flush()
    server.serve_forever()

if __name__ == "__main__":
    main()
