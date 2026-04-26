# Solution: Use Docker Logs to Find Issues

## What the validator checks

- ~/error-report.txt not found
- first line should contain the failing container name (app2)
- second line should contain the error message

## Solution

```bash
# Check logs for each container
docker logs app1
docker logs app2
docker logs app3

# Find the one with errors
for c in app1 app2 app3; do
  echo "=== $c ==="
  docker logs $c 2>&1 | grep -i error | head -3
done

# Write the report (container name on line 1, error on line 2)
CONTAINER="app2"
ERROR=$(docker logs $CONTAINER 2>&1 | grep ERROR | head -1)
printf "%s\n%s\n" "$CONTAINER" "$ERROR" > ~/error-report.txt
```
