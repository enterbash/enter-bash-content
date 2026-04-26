# Solution: Create Custom Docker Networks

## Approach

Create a custom network and run containers that can communicate by name.

```bash
docker network create mynet

docker run -d --name web --network mynet nginx:alpine
docker run -d --name tester --network mynet alpine sleep infinity

# Verify DNS resolution
docker exec tester ping -c 2 web
docker exec tester wget -qO- http://web
```

## Why this works

Containers on the same custom network can reach each other by container name. The default bridge network doesn't support this — you need a user-defined network.
