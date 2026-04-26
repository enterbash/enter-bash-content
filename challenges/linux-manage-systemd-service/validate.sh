#!/bin/bash

# Check service file exists
if [ ! -f /etc/systemd/system/myapp.service ]; then
  echo "FAIL: /etc/systemd/system/myapp.service does not exist"
  exit 1
fi

# Validate service file has required sections
if ! grep -q '^\[Unit\]' /etc/systemd/system/myapp.service; then
  echo "FAIL: Service file missing [Unit] section"
  exit 1
fi
if ! grep -q '^\[Service\]' /etc/systemd/system/myapp.service; then
  echo "FAIL: Service file missing [Service] section"
  exit 1
fi
if ! grep -q '^\[Install\]' /etc/systemd/system/myapp.service; then
  echo "FAIL: Service file missing [Install] section"
  exit 1
fi

# Check ExecStart points to the python server
if ! grep -q 'ExecStart.*server\.py\|ExecStart.*python.*8080' /etc/systemd/system/myapp.service; then
  echo "FAIL: ExecStart should run /opt/myapp/server.py"
  exit 1
fi

# Check WantedBy=multi-user.target (enables on boot)
if ! grep -q 'WantedBy=multi-user.target' /etc/systemd/system/myapp.service; then
  echo "FAIL: WantedBy should be multi-user.target"
  exit 1
fi

# Manually start the app to verify it actually works
pkill -f 'server.py' 2>/dev/null || true
sleep 1
python3 /opt/myapp/server.py &
APP_PID=$!
sleep 2

RESPONSE=$(curl -sf http://localhost:8080 2>/dev/null || true)
kill "$APP_PID" 2>/dev/null || true

if ! echo "$RESPONSE" | grep -q 'myapp is running'; then
  echo "FAIL: /opt/myapp/server.py does not respond correctly on port 8080"
  exit 1
fi

echo "PASS: Service file is valid and app runs correctly"
exit 0
