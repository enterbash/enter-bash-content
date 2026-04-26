# Solution: Optimize Docker Image Layers

## Approach

Optimize the Dockerfile to minimize layer count and image size.

```dockerfile
# Bloated (each RUN creates a layer, apt cache not cleaned)
FROM ubuntu:22.04
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN rm -rf /var/lib/apt/lists/*

# Optimized (single RUN, cache cleaned in same layer)
FROM ubuntu:22.04
RUN apt-get update &&     apt-get install -y --no-install-recommends curl wget &&     rm -rf /var/lib/apt/lists/*
```

```bash
docker build -t bloated:latest -f Dockerfile.bloated .
docker build -t optimized:latest -f Dockerfile.optimized .
docker images | grep -E 'bloated|optimized'
```

## Why this works

Each `RUN` instruction creates a new layer. Combining commands with `&&` reduces layers. Cleaning apt cache in the same `RUN` actually removes it (cleaning in a later layer doesn't reduce size).
