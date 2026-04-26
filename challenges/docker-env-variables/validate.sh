#!/bin/bash

# Check envbox
if ! docker ps --format '{{.Names}}' | grep -q '^envbox$'; then
  echo "FAIL: envbox container is not running"
  exit 1
fi

ENV1=$(docker exec envbox env 2>/dev/null)
if ! echo "$ENV1" | grep -q 'APP_ENV=production'; then
  echo "FAIL: APP_ENV not set to production"
  exit 1
fi
if ! echo "$ENV1" | grep -q 'APP_PORT=3000'; then
  echo "FAIL: APP_PORT not set to 3000"
  exit 1
fi
if ! echo "$ENV1" | grep -q 'APP_DEBUG=false'; then
  echo "FAIL: APP_DEBUG not set to false"
  exit 1
fi

# Check envbox2
if ! docker ps --format '{{.Names}}' | grep -q '^envbox2$'; then
  echo "FAIL: envbox2 container is not running"
  exit 1
fi

ENV2=$(docker exec envbox2 env 2>/dev/null)
if ! echo "$ENV2" | grep -q 'DB_HOST=localhost'; then
  echo "FAIL: DB_HOST not set in envbox2"
  exit 1
fi
if ! echo "$ENV2" | grep -q 'DB_PORT=5432'; then
  echo "FAIL: DB_PORT not set in envbox2"
  exit 1
fi

echo "PASS: all environment variables set correctly"
exit 0
