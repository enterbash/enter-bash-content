#!/bin/bash
set -e

# Create a memory-consuming script
cat > /tmp/mem_leak.sh <<'SCRIPT'
#!/bin/bash
# Simulate memory leak
DATA=""
while true; do
  DATA="${DATA}$(head -c 1024 /dev/urandom | base64)"
  sleep 5
done
SCRIPT
chmod +x /tmp/mem_leak.sh

# Create a CPU-consuming script
cat > /tmp/cpu_hog2.sh <<'SCRIPT'
#!/bin/bash
while true; do
  : $((RANDOM * RANDOM))
done
SCRIPT
chmod +x /tmp/cpu_hog2.sh

# Run them in background
bash /tmp/mem_leak.sh &
disown
bash /tmp/cpu_hog2.sh &
disown

# Remove any existing report
rm -f /home/runner/system-report.txt
