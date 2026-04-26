#!/bin/bash
set -e

# Create web content directory with files
mkdir -p /srv/www/html
echo '<!DOCTYPE html><html><body>Welcome</body></html>' > /srv/www/html/index.html
echo 'body { color: black; }' > /srv/www/html/style.css
echo 'console.log("loaded");' > /srv/www/html/app.js

# Set wrong extended attributes to simulate wrong SELinux context
for f in /srv/www/html/*; do
  setfattr -n user.selinux_type -v "default_t" "$f" 2>/dev/null || true
done

rm -f /home/runner/selinux-fix.log
rm -f /srv/www/html/.contexts
