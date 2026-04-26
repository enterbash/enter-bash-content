# Solution: Fix iptables Rules

## What the validator checks

- **Check loopback is allowed**: Loopback traffic is not allowed
- **Check port 80 is allowed**: HTTP (port 80) is not allowed
- **Check port 22 is allowed**: SSH (port 22) is not allowed
- Cannot reach web server on port 80

## Solution

```bash
sudo iptables -F
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -L -n
```
