#!/bin/bash
# Setup script — creates the HTML page and stops nginx
mkdir -p /var/www/html
cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head><title>Enter Bash</title></head>
<body><h1>Welcome to Enter Bash!</h1><p>You fixed the Nginx configuration.</p></body>
</html>
HTML
systemctl stop nginx 2>/dev/null || true
