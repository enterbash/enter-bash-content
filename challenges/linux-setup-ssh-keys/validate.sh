#!/bin/bash
set -e

# Check private key exists
if [ ! -f /home/runner/.ssh/id_ed25519 ]; then
  echo "FAIL: ~/.ssh/id_ed25519 does not exist"
  exit 1
fi

# Check public key exists
if [ ! -f /home/runner/.ssh/id_ed25519.pub ]; then
  echo "FAIL: ~/.ssh/id_ed25519.pub does not exist"
  exit 1
fi

# Check it's an Ed25519 key
if ! grep -q 'ssh-ed25519' /home/runner/.ssh/id_ed25519.pub; then
  echo "FAIL: Key is not Ed25519 type"
  exit 1
fi

# Check authorized_keys exists and contains the public key
if [ ! -f /home/runner/.ssh/authorized_keys ]; then
  echo "FAIL: ~/.ssh/authorized_keys does not exist"
  exit 1
fi

PUBKEY=$(cat /home/runner/.ssh/id_ed25519.pub)
if ! grep -qF "$PUBKEY" /home/runner/.ssh/authorized_keys; then
  echo "FAIL: Public key not found in authorized_keys"
  exit 1
fi

# Check permissions
DIR_PERMS=$(stat -c '%a' /home/runner/.ssh)
if [ "$DIR_PERMS" != "700" ]; then
  echo "FAIL: ~/.ssh/ should be 700, got $DIR_PERMS"
  exit 1
fi

KEY_PERMS=$(stat -c '%a' /home/runner/.ssh/id_ed25519)
if [ "$KEY_PERMS" != "600" ]; then
  echo "FAIL: id_ed25519 should be 600, got $KEY_PERMS"
  exit 1
fi

AK_PERMS=$(stat -c '%a' /home/runner/.ssh/authorized_keys)
if [ "$AK_PERMS" != "600" ] && [ "$AK_PERMS" != "644" ]; then
  echo "FAIL: authorized_keys should be 600 or 644, got $AK_PERMS"
  exit 1
fi

echo "PASS: SSH keys are properly generated and configured"
exit 0
