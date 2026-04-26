# Solution: Handle Signals in Containers

## Approach

Fix the Dockerfile to use exec form entrypoint so signals reach the process.

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
# Should show: [python3 app.py] — not [/bin/sh -c python3 app.py]
```

## Why this works

Shell form wraps the command in `/bin/sh -c`, making the shell PID 1. Signals like SIGTERM go to the shell, not your app. Exec form makes your app PID 1 directly.
