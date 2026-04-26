#!/bin/bash
set -e
mkdir -p /home/learner/app/logs

# Create deploy script (no execute permission)
cat > /home/learner/app/deploy.sh <<'SCRIPT'
#!/bin/bash
CONFIG=$(cat /home/learner/app/config.txt)
echo "[$(date)] Deployed with config: $CONFIG" >> /home/learner/app/logs/deploy.log
echo "Deployment successful!"
SCRIPT

# Create config file (no read permission for user)
echo "version=1.0.0" > /home/learner/app/config.txt

# Remove permissions
chmod 000 /home/learner/app/deploy.sh
chmod 000 /home/learner/app/config.txt
chmod 000 /home/learner/app/logs

chown learner:learner -R /home/learner/app
