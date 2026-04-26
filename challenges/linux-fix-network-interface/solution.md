# Solution: Fix Network Interface

## What the validator checks

- **Check dummy0 exists and is UP**: dummy0 interface is not UP
- **Check correct IP is assigned**: dummy0 does not have IP 10.0.0.10/24
- **Check wrong IP is removed**: Old IP 192.168.99.99 is still assigned

## Solution

```bash
sudo ip addr del 192.168.99.99/24 dev dummy0
sudo ip addr add 10.0.0.10/24 dev dummy0
sudo ip link set dummy0 up
ip addr show dummy0
```
