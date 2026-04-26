# Solution: Copy Files In and Out of Containers

## What the validator checks

- ~/extracted.log not found on host
- ~/extracted.log is empty
- /etc/inject.conf not found in container
- /etc/inject.conf doesn't contain mode=active

## Solution

```bash
# Copy FROM container TO host
docker cp filebox:/var/log/app.log ~/extracted.log

# Copy FROM host TO container
echo "mode=active" > ~/inject.conf
docker cp ~/inject.conf filebox:/etc/inject.conf

# Verify
cat ~/extracted.log
docker exec filebox cat /etc/inject.conf
```
