# Solution: Fix SSH Config Permissions

## Approach

Fix the SSH file permissions to match what SSH requires.

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/authorized_keys
```

## Why this works

SSH refuses to use keys with overly permissive permissions. The required permissions are: `.ssh/` → 700, private key → 600, public key → 644, config → 600, authorized_keys → 600 or 644.
