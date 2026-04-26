# Solution: Set Up Log Rotation

## Approach

Create a logrotate configuration file for the application logs.

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

# Test the configuration
sudo logrotate -d /etc/logrotate.d/myapp
```

## Why this works

`daily` rotates every day, `rotate 7` keeps 7 old logs, `compress` gzips old logs, `missingok` doesn't error if log is missing, `notifempty` skips empty logs.
