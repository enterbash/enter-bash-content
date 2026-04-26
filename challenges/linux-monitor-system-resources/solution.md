# Solution: Monitor System Resources

## What the validator checks

- **Check rogue processes are killed**: mem_leak process is still running
- cpu_hog2 process is still running
- **Check system report exists**: /home/runner/system-report.txt not found
- **Check report has content**: System report is empty
- **Check report contains memory info**: Report missing memory information

## Solution

```bash
# Kill rogue processes
pkill -f mem_leak
pkill -f cpu_hog2

# Write system report
cat > /home/runner/system-report.txt << EOF
CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%
Memory: $(free -h | awk '/^Mem:/{print $3 "/" $2}')
Rogue processes terminated
EOF
```
