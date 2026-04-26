# Solution: Create Swap Space

## What the validator checks

- **Check swap file exists**: /swapfile does not exist
- /swapfile permissions should be 600, got <value>
- **Check swap is active**: /swapfile is not active as swap
- **Check fstab entry**: /swapfile not found in /etc/fstab

## Solution

```bash
sudo dd if=/dev/zero of=/swapfile bs=1M count=512
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo swapon --show
```
