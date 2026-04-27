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
        if re.search(r"(anomal|detect|spike|threshold)", prompt):
            return json.dumps({
                "anomalies_detected": True,
                "anomalies": [
                    {"metric": "cpu_usage", "value": 95.2, "baseline": 35.0, "severity": "critical"},
                    {"metric": "memory_usage", "value": 88.7, "baseline": 45.0, "severity": "warning"}
                ],
                "analysis": "Significant deviation from baseline detected in CPU and memory metrics."
            })
        if re.search(r"(correlat|root.?cause|rca|diagnos)", prompt):
            return json.dumps({
                "root_cause": "Stress injection caused CPU saturation leading to increased memory pressure",
                "correlated_events": ["CPU spike at T+0s", "Memory pressure at T+5s", "Latency increase at T+10s"],
                "confidence": 0.9
            })
        if re.search(r"(remediat|action|fix|scale|restart)", prompt):
            return json.dumps({
                "recommended_actions": [
                    {"action": "scale_up", "target": "web-service", "replicas": 5, "priority": "high"},
                    {"action": "alert", "target": "oncall", "message": "CPU saturation detected", "priority": "critical"}
                ],
                "automated": True
            })
        if re.search(r"(summar|report|pipeline|overview)", prompt):
            return json.dumps({
                "summary": "Full AIOps pipeline executed: detected CPU/memory anomalies from stress injection, correlated events, identified root cause, and recommended scaling actions.",
                "pipeline_stages_completed": 5,
                "total_anomalies": 2,
                "actions_taken": 2
            })
        return json.dumps({
            "response": "Analysis complete. System shows signs of resource pressure.",
            "confidence": 0.7
        })

def main():
    port = int(os.environ.get("MOCK_LLM_PORT", 8080))
    server = HTTPServer(("0.0.0.0", port), MockLLMHandler)
    print(f"Mock LLM server running on port {port}")
    sys.stdout.flush()
    server.serve_forever()

if __name__ == "__main__":
    main()
