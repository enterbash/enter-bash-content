# Solution: Manage a systemd Service

## Approach

Create a valid systemd service unit file for the application.

```bash
sudo tee /etc/systemd/system/myapp.service << 'EOF'
[Unit]
Description=My Application Service
After=network.target

[Service]
Type=simple
User=runner
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/python3 /opt/myapp/server.py
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Verify the app actually runs
python3 /opt/myapp/server.py &
sleep 2
curl -sf http://localhost:8080
kill %1
```

## Why this works

`[Unit]` describes the service and its dependencies. `[Service]` defines how to run it. `[Install]` controls when it starts at boot. `WantedBy=multi-user.target` enables it for normal multi-user mode.
