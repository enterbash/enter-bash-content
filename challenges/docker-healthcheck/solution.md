# Solution: Add a Healthcheck to a Container

## What the validator checks

- healthyweb container is not running
- no healthcheck configured

## Solution

```bash
docker run -d \
  --name healthyweb \
  --health-cmd "wget -qO- http://localhost/ || exit 1" \
  --health-interval 10s \
  --health-timeout 5s \
  --health-retries 3 \
  nginx:alpine

sleep 15
docker inspect healthyweb --format '{{.State.Health.Status}}'
```
