# Solution: Fix Broken APT Sources

## Approach

Fix the APT sources list to use a valid mirror and update the package cache.

```bash
# Backup current sources
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Fix the sources list
sudo tee /etc/apt/sources.list << 'EOF'
deb http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu noble-security main restricted universe multiverse
EOF

# Update package cache
sudo apt-get update

# Verify
apt-cache show curl | head -5
```

## Why this works

A broken mirror URL or wrong distribution codename causes `apt-get update` to fail. Using the official Ubuntu archive with the correct codename fixes it.
