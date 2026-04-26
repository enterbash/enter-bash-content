# Solution: Fix Timezone

## Approach

Set the system timezone to America/New_York.

```bash
# Set timezone
sudo timedatectl set-timezone America/New_York
# or
sudo ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
echo "America/New_York" | sudo tee /etc/timezone

# Verify
timedatectl
date
```

## Why this works

`/etc/localtime` is a symlink to the timezone data file. `/etc/timezone` stores the timezone name as text. Both need to be consistent.
