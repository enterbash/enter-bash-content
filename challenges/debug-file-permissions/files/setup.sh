#!/bin/bash
set -e
mkdir -p /home/runner/app/logs

# Create deploy script (no execute permission)
cat > /home/runner/app/deploy.sh <<'SCRIPT'
#!/bin/bash
CONFIG=$(cat /home/runner/app/config.txt)
echo "[$(date)] Deployed with config: $CONFIG" >> /home/runner/app/logs/deploy.log
echo "Deployment successful!"
SCRIPT

# Create config file (no read permission for user)
echo "version=1.0.0" > /home/runner/app/config.txt

# Remove permissions
chmod 000 /home/runner/app/deploy.sh
chmod 000 /home/runner/app/config.txt
chmod 000 /home/runner/app/logs

chown runner:runner -R /home/runner/app
