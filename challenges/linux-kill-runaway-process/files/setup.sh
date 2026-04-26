#!/bin/bash
set -e

# Create a CPU-hogging script
cat > /tmp/cpu_hog.sh <<'SCRIPT'
#!/bin/bash
while true; do
  : $((RANDOM * RANDOM))
done
SCRIPT
chmod +x /tmp/cpu_hog.sh

# Run it in the background with a recognizable name
bash /tmp/cpu_hog.sh &
disown
