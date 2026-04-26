# Solution: Set Up SSH Keys

## Approach

Generate an SSH key pair and configure the correct permissions.

```bash
# Generate key pair (no passphrase for automation)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Set correct permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Add public key to authorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Create SSH config
cat > ~/.ssh/config << 'EOF'
Host localhost
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
EOF
chmod 600 ~/.ssh/config
```

## Why this works

SSH enforces strict permission requirements. Private keys must be `600` (owner read/write only). The `.ssh` directory must be `700`.
