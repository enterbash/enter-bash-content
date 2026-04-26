#!/bin/bash
# Setup script — creates the HTML page and stops nginx
sudo mkdir -p /var/www/html
sudo tee /var/www/html/index.html <<'HTML' > /dev/null
<!DOCTYPE html>
<html>
<head><title>Enter Bash</title></head>
<body><h1>Welcome to Enter Bash!</h1><p>You fixed the Nginx configuration.</p></body>
</html>
HTML
service nginx stop 2>/dev/null || true
