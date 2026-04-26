# Solution: Fix SSH Config Permissions

## What the validator checks

- ~/.ssh/ should be 700, got $PERMS
- id_rsa should be 600, got $PERMS
- id_rsa.pub should be 644, got $PERMS
- config should be 600, got $PERMS
- authorized_keys should be 600 or 644, got $PERMS

## Solution

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa 2>/dev/null || true
chmod 644 ~/.ssh/id_rsa.pub 2>/dev/null || true
chmod 600 ~/.ssh/config 2>/dev/null || true
chmod 600 ~/.ssh/authorized_keys
```

SSH refuses to use keys with overly permissive permissions.
