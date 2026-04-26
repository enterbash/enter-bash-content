#!/bin/bash
set -e

# Create source project with various files
mkdir -p /home/runner/project/{src,docs,.git/objects}
echo 'console.log("hello");' > /home/runner/project/src/app.js
echo '# Project Docs' > /home/runner/project/docs/README.md
echo '{"name": "myproject"}' > /home/runner/project/package.json
echo 'ref: refs/heads/main' > /home/runner/project/.git/HEAD
echo 'git object data' > /home/runner/project/.git/objects/abc123
mkdir -p /home/runner/project/node_modules/lodash
echo 'module.exports = {};' > /home/runner/project/node_modules/lodash/index.js

# Create empty backup dir
mkdir -p /home/runner/backup

# Remove any existing backup script
rm -f /home/runner/run-backup.sh

chown -R runner:runner /home/runner/project /home/runner/backup
