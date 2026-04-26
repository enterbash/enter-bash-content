#!/bin/bash

# Check .ssh directory permissions (should be 700)
PERMS=$(stat -c '%a' /home/runner/.ssh)
if [ "$PERMS" != "700" ]; then
  echo "FAIL: ~/.ssh/ should be 700, got $PERMS"
  exit 1
fi

# Check private key permissions (should be 600)
PERMS=$(stat -c '%a' /home/runner/.ssh/id_rsa)
if [ "$PERMS" != "600" ]; then
  echo "FAIL: id_rsa should be 600, got $PERMS"
  exit 1
fi

# Check public key permissions (should be 644)
PERMS=$(stat -c '%a' /home/runner/.ssh/id_rsa.pub)
if [ "$PERMS" != "644" ]; then
  echo "FAIL: id_rsa.pub should be 644, got $PERMS"
  exit 1
fi

# Check config permissions (should be 600)
PERMS=$(stat -c '%a' /home/runner/.ssh/config)
if [ "$PERMS" != "600" ]; then
  echo "FAIL: config should be 600, got $PERMS"
  exit 1
fi

# Check authorized_keys permissions (should be 600)
PERMS=$(stat -c '%a' /home/runner/.ssh/authorized_keys)
if [ "$PERMS" != "600" ]; then
  echo "FAIL: authorized_keys should be 600, got $PERMS"
  exit 1
fi

echo "PASS: All SSH permissions are correct"
exit 0
