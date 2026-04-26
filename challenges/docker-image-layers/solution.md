# Solution: Optimize Docker Image Layers

## What the validator checks

- optimized:latest image not found
- optimized image ($OPTIMIZED_SIZE) is not smaller than bloated ($BLOATED_SIZE)

## Solution

Combine `RUN` commands and clean apt cache in the same layer:

```dockerfile
FROM ubuntu:22.04
# Bad: each RUN creates a layer, cache not cleaned
# RUN apt-get update
# RUN apt-get install -y curl

# Good: single layer, cache cleaned in same RUN
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    rm -rf /var/lib/apt/lists/*
```

```bash
docker build -t optimized:latest ~/myapp/
docker history optimized:latest
```
