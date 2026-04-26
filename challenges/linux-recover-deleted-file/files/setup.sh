#!/bin/bash
set -e

mkdir -p /home/runner/app

# Create the config file
cat > /home/runner/app/config.json <<'JSON'
{
  "database": {
    "host": "localhost",
    "port": 5432,
    "name": "myapp",
    "user": "admin"
  },
  "cache": {
    "enabled": true,
    "ttl": 3600
  }
}
JSON

# Start a process that holds the file open, then delete it
(exec 3< /home/runner/app/config.json; sleep 86400) &
disown

# Wait a moment for the process to open the file
sleep 1

# Delete the original file
rm /home/runner/app/config.json
