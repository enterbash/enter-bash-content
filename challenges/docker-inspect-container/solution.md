# Solution: Use Docker Inspect to Find Information

## Approach

Use `docker inspect` to extract container metadata and write a report.

```bash
# Get all info
docker inspect mystery

# Extract specific fields
IP=$(docker inspect mystery --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
IMAGE=$(docker inspect mystery --format '{{.Config.Image}}')
HOSTNAME=$(docker inspect mystery --format '{{.Config.Hostname}}')
PORTS=$(docker inspect mystery --format '{{json .NetworkSettings.Ports}}')

# Write report
cat > ~/report.txt << EOF
Container: mystery
IP Address: $IP
Image: $IMAGE
Hostname: $HOSTNAME
Ports: $PORTS
EOF
```

## Why this works

`docker inspect` returns JSON. `--format` uses Go templates to extract specific fields. `{{range}}` iterates over maps/slices.
