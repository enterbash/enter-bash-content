# Solution: Fix Timezone

## What the validator checks

- Timezone is not America/New_York (got: $TZ_FILE)

## Solution

```bash
sudo timedatectl set-timezone America/New_York
# or:
sudo ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
echo "America/New_York" | sudo tee /etc/timezone
timedatectl
```
