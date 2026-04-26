# Solution: Monitor System Resources

## Approach

Kill the rogue processes and write a system resource report.

```bash
# Kill rogue processes
pkill -f mem_leak
pkill -f cpu_hog2

# Write system report
cat > /home/runner/system-report.txt << EOF
CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%
Memory: $(free -h | awk '/^Mem:/{print $3 "/" $2}')
Load Average: $(uptime | awk -F'load average:' '{print $2}')
EOF

echo "Rogue processes terminated" >> /home/runner/system-report.txt
```

## Why this works

`pkill -f` kills by command pattern. The report file needs to exist with content — the exact format is flexible.
