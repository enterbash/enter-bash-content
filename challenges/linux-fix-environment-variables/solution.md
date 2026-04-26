# Solution: Fix Environment Variables

## Approach

Add the required environment variables to `~/.bashrc` and source it.

```bash
# Add to .bashrc
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

# Run the app to create the flag file
bash /home/runner/app/start.sh
```

## Why this works

`export` makes variables available to child processes. Sourcing `.bashrc` applies them to the current shell session.
