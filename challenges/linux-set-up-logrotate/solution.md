# Solution: Set Up Log Rotation

## What the validator checks

- **Check logrotate config exists**: /etc/logrotate.d/myapp does not exist
- Config missing 'daily' directive
- Config missing 'rotate' directive
- Config missing 'compress' directive
- Config does not reference /var/log/myapp
- Logrotate config has errors:

## Solution

```bash
sudo tee /etc/logrotate.d/myapp << 'EOF'
/var/log/myapp/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 runner runner
}
EOF

sudo logrotate -d /etc/logrotate.d/myapp  # dry-run to verify
```
