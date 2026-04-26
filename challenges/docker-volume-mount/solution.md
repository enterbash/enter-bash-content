# Solution: Mount Volumes Correctly

## Approach

Run a container with a volume mount to persist data.

```bash
# Create a named volume
docker volume create mydata

# Run container with volume
docker run -d   --name databox   -v mydata:/data   alpine sleep infinity

# Or bind mount a host directory
docker run -d   --name databox   -v ~/mydata:/data   alpine sleep infinity

# Write data and verify persistence
docker exec databox sh -c "echo 'hello' > /data/test.txt"
docker rm -f databox
docker run --rm -v mydata:/data alpine cat /data/test.txt
```

## Why this works

Named volumes persist beyond container lifecycle. Bind mounts link a host directory directly into the container.
