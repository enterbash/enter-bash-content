# Solution: Configure sudo Access

## Approach

Grant the `developer` user sudo access for specific commands.

```bash
# Create a sudoers drop-in file (safer than editing /etc/sudoers directly)
echo "developer ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/systemctl" | sudo tee /etc/sudoers.d/developer
sudo chmod 0440 /etc/sudoers.d/developer

# Verify syntax
sudo visudo -c -f /etc/sudoers.d/developer

# Test
sudo -l -U developer
```

## Why this works

Drop-in files in `/etc/sudoers.d/` are included by the main sudoers file. `NOPASSWD:` allows running without a password prompt. Always use `visudo -c` to validate syntax before applying.
