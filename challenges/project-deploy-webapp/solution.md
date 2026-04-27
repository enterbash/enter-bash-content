# Solution: Deploy a Web Application Stack

## What the validator checks

- ~/webapp/docker-compose.yml not found
- ~/webapp/Dockerfile not found
- app service is not running — run 'docker compose up -d'
- nginx service is not running — run 'docker compose up -d'
- No response from http://localhost:8080 — check nginx proxy_pass config
- Response does not contain expected JSON — got: <value>
- Response does not contain 'Enter Bash' — got: <value>

## Solution

```bash
# Fix: Docker daemon is not running or not accessible
# Fix: ~/webapp/docker-compose.yml not found
# Fix: ~/webapp/Dockerfile not found
# Fix: app service is not running — run 'docker compose up -d'
# Fix: nginx service is not running — run 'docker compose up -d'
```
