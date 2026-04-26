# Solution: Configure Bridge Networking

## What the validator checks

- appnet subnet is not 172.20.0.0/16 (got $SUBNET)
- webhost container is not running
- webhost IP is not 172.20.0.10 (got $WEBIP)
- checker container is not running
- checker cannot reach webhost

## Solution

```bash
docker network create \
  --driver bridge \
  --subnet 172.20.0.0/16 \
  --gateway 172.20.0.1 \
  appnet

docker run -d \
  --name webhost \
  --network appnet \
  --ip 172.20.0.10 \
  nginx:alpine

docker run -d \
  --name checker \
  --network appnet \
  alpine sleep infinity

# Verify DNS resolution by container name
docker exec checker ping -c 2 webhost
```
