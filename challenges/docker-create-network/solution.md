# Solution: Create Custom Docker Networks

## What the validator checks

- mynet network not found
- web container is not running
- tester container is not running
- web is not on mynet network
- tester is not on mynet network
- tester cannot reach web

## Solution

```bash
docker network create mynet

docker run -d --name web --network mynet nginx:alpine
docker run -d --name tester --network mynet alpine sleep infinity

# Verify containers can reach each other by name
docker exec tester ping -c 2 web
docker exec tester wget -qO- http://web
```
