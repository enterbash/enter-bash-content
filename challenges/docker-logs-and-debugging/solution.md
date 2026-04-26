# Solution: Use Docker Logs to Find Issues

## Approach

Use `docker logs` to find the failing container and extract the error.

```bash
# Check logs for each container
docker logs app1
docker logs app2
docker logs app3

# Find the one with errors
docker logs app2 2>&1 | grep ERROR

# Write the report
CONTAINER="app2"
ERROR=$(docker logs $CONTAINER 2>&1 | grep ERROR | head -1)

cat > ~/error-report.txt << EOF
$CONTAINER
$ERROR
EOF
```

## Why this works

`docker logs` shows stdout and stderr from a container. `2>&1` merges stderr into stdout for piping. The report needs the container name on line 1 and the error on line 2.
