#!/bin/bash
set -e

# Create web content directory with files
sudo mkdir -p /srv/www/html
echo '<!DOCTYPE html><html><body>Welcome</body></html>' | sudo tee /srv/www/html/index.html > /dev/null
echo 'body { color: black; }' | sudo tee /srv/www/html/style.css > /dev/null
echo 'console.log("loaded");' | sudo tee /srv/www/html/app.js > /dev/null

# Set wrong extended attributes to simulate wrong SELinux context
for f in /srv/www/html/*; do
  setfattr -n user.selinux_type -v "default_t" "$f" 2>/dev/null || true
done

rm -f /home/runner/selinux-fix.log
rm -f /srv/www/html/.contexts
