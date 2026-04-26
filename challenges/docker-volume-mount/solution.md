# Solution: Mount Volumes Correctly

## What the validator checks

- databox container is not running
- /data volume mount not found
- config.txt not accessible inside container
- output.txt not found in /data

## Solution

```bash
# Create a named volume and mount it
docker volume create mydata

docker run -d \
  --name databox \
  -v mydata:/data \
  alpine sleep infinity

# Write data and verify it persists
docker exec databox sh -c "echo 'hello' > /data/test.txt"
docker exec databox cat /data/test.txt
```
