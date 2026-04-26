# Solution: Fix a Docker Compose File

## Approach

Fix the two errors in `docker-compose.yml`: the image typo and the indentation.

```yaml
version: "3"
services:
  web:
    image: nginx:alpine      # fix: "ngix" → "nginx"
    ports:
      - "8080:80"
  api:
    image: python:3-alpine   # fix: indentation (was under "web")
    ports:
      - "5000:5000"
    command: python -m http.server 5000
```

```bash
docker compose -f ~/project/docker-compose.yml up -d
docker compose -f ~/project/docker-compose.yml ps
```

## Why this works

The `api` service block was indented under `web`, making it a property of `web` rather than a sibling service. The image name `ngix` was a typo.
