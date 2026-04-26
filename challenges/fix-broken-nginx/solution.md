# Solution: Fix Broken Nginx Config

## What the validator checks

- **Check nginx is running**: Nginx is not running
- **Check nginx config is valid**: Nginx configuration is invalid — run 'sudo nginx -t' to see errors
- Nginx is not serving the expected content

## Solution

```bash
# Check what's wrong with the nginx config
sudo nginx -t

# Common fixes:
# - Wrong server_name or listen port
# - Missing semicolons
# - Wrong root path

# After fixing /etc/nginx/nginx.conf or /etc/nginx/sites-enabled/*:
sudo nginx -t   # must pass
sudo service nginx start
curl http://localhost
```
