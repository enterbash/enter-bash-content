#!/bin/bash
set -e

mkdir -p /home/runner/myapp/current

# Create actual files in current/
echo "DB_HOST=localhost" > /home/runner/myapp/current/config.env
echo "#!/bin/bash" > /home/runner/myapp/current/start.sh
chmod +x /home/runner/myapp/current/start.sh
echo "v2.1.0" > /home/runner/myapp/current/version.txt
mkdir -p /home/runner/myapp/current/lib
echo "module.exports = {};" > /home/runner/myapp/current/lib/utils.js

# Create broken symlinks pointing to old/deleted paths
ln -sf /home/runner/myapp/old/config.env /home/runner/myapp/config.env
ln -sf /home/runner/myapp/old/start.sh /home/runner/myapp/start.sh
ln -sf /home/runner/myapp/old/version.txt /home/runner/myapp/version.txt
ln -sf /home/runner/myapp/old/lib /home/runner/myapp/lib
