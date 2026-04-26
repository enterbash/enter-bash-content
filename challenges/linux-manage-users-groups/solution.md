# Solution: Manage Users and Groups

## What the validator checks

- **Check devteam group exists**: Group 'devteam' does not exist
- **Check alice exists and is in devteam**: User 'alice' does not exist
- User 'alice' is not in group 'devteam'
- **Check bob exists and is in devteam**: User 'bob' does not exist
- User 'bob' is not in group 'devteam'
- **Check /opt/project exists**: /opt/project does not exist
- /opt/project group should be 'devteam', got '<value>'
- **Check group write permission**: /opt/project should be group-writable
- **Check setgid bit**: /opt/project should have setgid bit set

## Solution

```bash
sudo groupadd developers
sudo useradd -m -s /bin/bash alice
sudo useradd -m -s /bin/bash bob
sudo usermod -aG developers alice
sudo usermod -aG developers bob
sudo mkdir -p /home/shared
sudo chown root:developers /home/shared
sudo chmod 2775 /home/shared   # setgid: new files inherit group
```
