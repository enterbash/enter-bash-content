# Solution: Fix Environment Variables

## What the validator checks

- **Check .bashrc has the env vars**: APP_HOME not set in .bashrc
- APP_PORT not set in .bashrc
- APP_ENV not set in .bashrc
- **Check the app was started (running flag exists)**: App has not been started — run ~/app/start.sh
- **Check the flag has correct values**: App started with wrong environment values

## Solution

```bash
# Add required environment variables to ~/.bashrc
cat >> ~/.bashrc << 'EOF'
export APP_HOME=/home/runner/app
export APP_PORT=8080
export APP_ENV=production
export LOG_DIRECTORY=/home/runner/app/logs
EOF

# Apply immediately
source ~/.bashrc

# Verify
echo $APP_HOME $APP_PORT $APP_ENV
```
