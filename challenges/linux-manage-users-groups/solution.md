# Solution: Manage Users and Groups

## Approach

Create the required users, groups, and shared directory with correct permissions.

```bash
# Create group
sudo groupadd developers

# Create users
sudo useradd -m -s /bin/bash alice
sudo useradd -m -s /bin/bash bob

# Add to group
sudo usermod -aG developers alice
sudo usermod -aG developers bob

# Create shared directory
sudo mkdir -p /home/shared
sudo chown root:developers /home/shared
sudo chmod 2775 /home/shared  # setgid so new files inherit group
```

## Why this works

`chmod 2775` sets the setgid bit — new files created in the directory automatically inherit the `developers` group. `775` gives group write access.
