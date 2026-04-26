# Solution: Configure sudo Access

## What the validator checks

- **Check sudoers file exists**: /etc/sudoers.d/developer does not exist
- **Check sudoers syntax is valid**: sudoers configuration has syntax errors
- **Check developer can run systemctl**: developer cannot run systemctl via sudo
- **Check developer can run journalctl**: developer cannot run journalctl via sudo
- **Check NOPASSWD is set**: NOPASSWD not configured

## Solution

```bash
echo "developer ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/systemctl" \
  | sudo tee /etc/sudoers.d/developer
sudo chmod 0440 /etc/sudoers.d/developer
sudo visudo -c -f /etc/sudoers.d/developer
sudo -l -U developer
```
