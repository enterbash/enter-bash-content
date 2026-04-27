#!/bin/bash
set -e
python3 ~/mock_llm_server.py &
sleep 1
if curl -s http://localhost:8080/health | grep -q "ok"; then
  echo "Ready: Mock LLM server running on port 8080 (OpenAI-compatible)."
  echo "Use POST http://localhost:8080/v1/chat/completions to generate PromQL."
else
  echo "Warning: Mock LLM server may not have started. Try: python3 ~/mock_llm_server.py &"
fi
