# Solution: Pass Environment Variables to Containers

## Approach

Pass environment variables using `-e` flags or an env file.

```bash
# Using -e flags
docker run -d   --name envbox   -e APP_ENV=production   -e APP_PORT=3000   -e APP_DEBUG=false   alpine sleep infinity

# Create env file
cat > ~/app.env << 'EOF'
DB_HOST=localhost
DB_PORT=5432
EOF

# Run second container with env file
docker run -d   --name envbox2   --env-file ~/app.env   alpine sleep infinity

# Verify
docker exec envbox env | grep APP_
```

## Why this works

`-e KEY=VALUE` sets individual variables. `--env-file` reads from a file (one `KEY=VALUE` per line). Both are available inside the container via `env`.
