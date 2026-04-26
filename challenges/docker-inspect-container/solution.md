# Solution: Use Docker Inspect to Find Information

## What the validator checks

- ~/report.txt not found
- report.txt should have at least 4 lines
- IP address <value> not found in report
- image name not found in report
- hostname not found in report

## Solution

```bash
# Extract container metadata
IP=$(docker inspect mystery --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
IMAGE=$(docker inspect mystery --format '{{.Config.Image}}')
HOSTNAME=$(docker inspect mystery --format '{{.Config.Hostname}}')

cat > ~/report.txt << EOF
Container: mystery
IP Address: $IP
Image: $IMAGE
Hostname: $HOSTNAME
EOF
```
