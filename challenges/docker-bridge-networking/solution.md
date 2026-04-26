# Solution: Configure Bridge Networking

## Approach

Create a custom bridge network with a specific subnet and run containers on it.

```bash
# Create network with specific subnet
docker network create   --driver bridge   --subnet 172.20.0.0/16   --gateway 172.20.0.1   appnet

# Run containers on the network with specific IPs
docker run -d   --name webhost   --network appnet   --ip 172.20.0.10   nginx:alpine

docker run -d   --name checker   --network appnet   alpine sleep infinity

# Verify connectivity
docker exec checker ping -c 2 webhost
```

## Why this works

Custom bridge networks provide DNS resolution by container name. `--ip` assigns a static IP within the subnet.
