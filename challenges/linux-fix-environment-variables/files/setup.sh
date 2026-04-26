#!/bin/bash
set -e

mkdir -p /home/runner/app

# Create the app startup script
cat > /home/runner/app/start.sh <<'SCRIPT'
#!/bin/bash
if [ -z "$APP_HOME" ] || [ -z "$APP_PORT" ] || [ -z "$APP_ENV" ]; then
  echo "ERROR: Missing required environment variables"
  echo "Required: APP_HOME, APP_PORT, APP_ENV"
  exit 1
fi
echo "App started: home=$APP_HOME port=$APP_PORT env=$APP_ENV"
echo "$APP_HOME:$APP_PORT:$APP_ENV" > /home/runner/app/running.flag
SCRIPT
chmod +x /home/runner/app/start.sh

# Clear the .bashrc of any app env vars
sed -i '/APP_HOME\|APP_PORT\|APP_ENV/d' /home/runner/.bashrc 2>/dev/null || true

# Remove any running flag
rm -f /home/runner/app/running.flag

chown -R runner:runner /home/runner/app
