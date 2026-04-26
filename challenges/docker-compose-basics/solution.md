# Solution: Fix a Docker Compose File

## What the validator checks

- web service is not running
- api service is not running

## Solution

Fix the two errors in `docker-compose.yml`:

1. `ngix` → `nginx` (image name typo)
2. `api` service was indented under `web` — it must be a sibling

```yaml
version: "3"
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
  api:
    image: python:3-alpine
    ports:
      - "5000:5000"
    command: python -m http.server 5000
```

```bash
docker compose -f ~/project/docker-compose.yml up -d
docker compose -f ~/project/docker-compose.yml ps
```
