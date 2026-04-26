# Solution: Fix Broken APT Sources

## What the validator checks

- **Check that apt update succeeds**: apt update still fails
- **Check that broken PPA is removed**: Broken PPA file still exists
- **Check sources.list has valid entries**: Invalid sources still in sources.list

## Solution

```bash
sudo tee /etc/apt/sources.list << 'EOF'
deb http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu noble-security main restricted universe multiverse
EOF
sudo apt-get update
```
