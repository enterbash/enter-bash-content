# Solution: Pass Environment Variables to Containers

## What the validator checks

- envbox container is not running
- APP_ENV not set to production
- APP_PORT not set to 3000
- APP_DEBUG not set to false
- envbox2 container is not running
- DB_HOST not set in envbox2
- DB_PORT not set in envbox2

## Solution

```bash
# Run with -e flags
docker run -d \
  --name envbox \
  -e APP_ENV=production \
  -e APP_PORT=3000 \
  -e APP_DEBUG=false \
  alpine sleep infinity

# Create env file for second container
cat > ~/app.env << 'EOF'
DB_HOST=localhost
DB_PORT=5432
EOF

docker run -d \
  --name envbox2 \
  --env-file ~/app.env \
  alpine sleep infinity

# Verify
docker exec envbox env | grep APP_
```
