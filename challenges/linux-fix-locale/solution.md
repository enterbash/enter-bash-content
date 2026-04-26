# Solution: Fix Locale Settings

## What the validator checks

- **Check en_US.UTF-8 is available**: en_US.UTF-8 locale is not generated
- **Check LANG is set correctly in /etc/default/locale**: /etc/default/locale does not have LANG=en_US.UTF-8

## Solution

```bash
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
locale
```
