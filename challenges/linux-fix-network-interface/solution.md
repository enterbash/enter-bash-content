# Solution: Fix Network Interface

## Approach

Remove the wrong IP and assign the correct one to the dummy interface.

```bash
# Check current state
ip addr show dummy0

# Remove wrong IP
sudo ip addr del 192.168.99.99/24 dev dummy0

# Add correct IP
sudo ip addr add 10.0.0.10/24 dev dummy0

# Bring interface up
sudo ip link set dummy0 up

# Verify
ip addr show dummy0
```

## Why this works

`ip addr del` removes a specific address. `ip addr add` assigns the new one. `ip link set up` ensures the interface is active.
