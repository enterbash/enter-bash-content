# Solution: Fix iptables Rules

## Approach

Configure iptables rules to allow SSH and HTTP while blocking everything else.

```bash
# Flush existing rules
sudo iptables -F

# Set default policies
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Allow established connections
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
sudo iptables -A INPUT -i lo -j ACCEPT

# Allow SSH (port 22)
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP (port 80)
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Verify
sudo iptables -L -n
```

## Why this works

Starting with DROP policy and explicitly allowing only needed ports is the principle of least privilege. The ESTABLISHED rule allows responses to outbound connections.
