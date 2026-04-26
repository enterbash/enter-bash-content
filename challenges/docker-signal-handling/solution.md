# Solution: Handle Signals in Containers

## What the validator checks

- signalapp:fixed image not found
- still using shell form entrypoint

## Solution

Fix the Dockerfile to use exec form so signals reach the process:

```dockerfile
FROM python:3-alpine
WORKDIR /app
COPY app.py .
# Shell form (broken): ENTRYPOINT python3 app.py
# Exec form (fixed):
ENTRYPOINT ["python3", "app.py"]
```

```bash
docker build -t signalapp:fixed ~/signalapp/
docker inspect signalapp:fixed --format '{{.Config.Entrypoint}}'
# Should show: [python3 app.py]  — not [/bin/sh -c python3 app.py]
```
