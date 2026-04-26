# Solution: Fix Broken ENTRYPOINT/CMD

## What the validator checks

- myserver container is not running

## Solution

Fix the typo and switch to exec form (JSON array):

```dockerfile
FROM python:3-alpine
WORKDIR /app
COPY app.py .
# Fix: "pythonn" → "python3", use exec form not shell form
ENTRYPOINT ["python3", "app.py"]
```

```bash
docker build -t fixed-server:latest ~/server/
docker run -d --name myserver fixed-server:latest
docker ps | grep myserver
```

Exec form makes your app PID 1 — shell form wraps it in `/bin/sh -c`.
