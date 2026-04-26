# Solution: Set Up SSH Keys

## What the validator checks

- **Check private key exists**: ~/.ssh/id_ed25519 does not exist
- **Check public key exists**: ~/.ssh/id_ed25519.pub does not exist
- **Check it's an Ed25519 key**: Key is not Ed25519 type
- **Check authorized_keys exists and contains the public key**: ~/.ssh/authorized_keys does not exist
- Public key not found in authorized_keys
- ~/.ssh/ should be 700, got $DIR_PERMS
- id_ed25519 should be 600, got $KEY_PERMS
- authorized_keys should be 600 or 644, got $AK_PERMS

## Solution

```bash
# Generate Ed25519 key pair
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""

# Set correct permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Add to authorized_keys
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

The validator checks: key type is `ssh-ed25519`, public key is in `authorized_keys`, `.ssh/` is 700, private key is 600.
