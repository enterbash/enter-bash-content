# Solution: Manage a systemd Service

## What the validator checks

- **Check service file exists**: /etc/systemd/system/myapp.service does not exist
- **Validate service file has required sections**: Service file missing [Unit] section
- Service file missing [Service] section
- Service file missing [Install] section
- **Check ExecStart points to the python server**: ExecStart should run /opt/myapp/server.py
- **Check WantedBy=multi-user.target (enables on boot)**: WantedBy should be multi-user.target
- /opt/myapp/server.py does not respond correctly on port 8080

## Solution

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

[Install]
WantedBy=multi-user.target
EOF

# Verify the app runs
python3 /opt/myapp/server.py &
sleep 2 && curl -sf http://localhost:8080 && kill %1
```
