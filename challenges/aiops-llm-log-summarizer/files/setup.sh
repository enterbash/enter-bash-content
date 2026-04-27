#!/bin/bash
set -e
cp ~/sample_logs.txt ~/sample_logs.txt.bak 2>/dev/null || true
python3 ~/mock_llm_server.py &
sleep 1
# Verify server is running
if curl -s http://localhost:8080/health | grep -q "ok"; then
  echo "Ready: Mock LLM server running on port 8080."
  echo "Sample logs at ~/sample_logs.txt (500 lines showing a DB connection pool failure)."
else
  echo "Warning: Mock LLM server may not have started. Try: python3 ~/mock_llm_server.py &"
fi
