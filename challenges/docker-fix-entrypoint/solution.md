# Solution: Fix Broken ENTRYPOINT/CMD

## Approach

Fix the typo in the Dockerfile and change to exec form entrypoint.

```dockerfile
FROM python:3-alpine
WORKDIR /app
COPY app.py .
# Fix 1: "pythonn" → "python3"
# Fix 2: use exec form (JSON array) not shell form
ENTRYPOINT ["python3", "app.py"]
```

```bash
docker build -t fixed-server:latest ~/server/
docker run -d --name myserver fixed-server:latest
docker ps | grep myserver
```

## Why this works

Shell form (`ENTRYPOINT python3 app.py`) runs via `/bin/sh -c`, which means PID 1 is the shell, not your app. Exec form (`["python3", "app.py"]`) makes your app PID 1, enabling proper signal handling.
