# Solution: Create Swap Space

## Approach

Create a swap file, format it, and enable it permanently.

```bash
# Create a 512MB swap file
sudo dd if=/dev/zero of=/swapfile bs=1M count=512

# Set correct permissions
sudo chmod 600 /swapfile

# Format as swap
sudo mkswap /swapfile

# Enable swap
sudo swapon /swapfile

# Make permanent (add to fstab)
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Verify
sudo swapon --show
free -h
```

## Why this works

`mkswap` formats the file as a swap area. `swapon` activates it. Adding to `/etc/fstab` ensures it persists across reboots.
