#!/bin/bash
set -e

# Create a webapp directory with files
mkdir -p /home/runner/webapp/{src,config,public}
echo '<!DOCTYPE html><html><body>Hello</body></html>' > /home/runner/webapp/public/index.html
echo 'console.log("app");' > /home/runner/webapp/src/app.js
echo '{"name": "webapp", "version": "1.0.0"}' > /home/runner/webapp/config/settings.json
echo '# My Webapp' > /home/runner/webapp/README.md
echo 'node_modules/' > /home/runner/webapp/.gitignore

# Remove any existing archive
rm -f /home/runner/webapp-backup.tar.gz
