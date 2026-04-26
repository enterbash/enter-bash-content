#!/bin/bash

# Check devteam group exists
if ! getent group devteam > /dev/null 2>&1; then
  echo "FAIL: Group 'devteam' does not exist"
  exit 1
fi

# Check alice exists and is in devteam
if ! id alice > /dev/null 2>&1; then
  echo "FAIL: User 'alice' does not exist"
  exit 1
fi
if ! id alice | grep -q 'devteam'; then
  echo "FAIL: User 'alice' is not in group 'devteam'"
  exit 1
fi

# Check bob exists and is in devteam
if ! id bob > /dev/null 2>&1; then
  echo "FAIL: User 'bob' does not exist"
  exit 1
fi
if ! id bob | grep -q 'devteam'; then
  echo "FAIL: User 'bob' is not in group 'devteam'"
  exit 1
fi

# Check /opt/project exists
if [ ! -d /opt/project ]; then
  echo "FAIL: /opt/project does not exist"
  exit 1
fi

# Check group ownership
DIR_GROUP=$(stat -c '%G' /opt/project)
if [ "$DIR_GROUP" != "devteam" ]; then
  echo "FAIL: /opt/project group should be 'devteam', got '$DIR_GROUP'"
  exit 1
fi

# Check group write permission
if [ ! -w /opt/project ] || ! stat -c '%A' /opt/project | grep -q 'rwx..w'; then
  PERMS=$(stat -c '%a' /opt/project)
  if [ "${PERMS:1:1}" -lt 7 ] 2>/dev/null; then
    echo "FAIL: /opt/project should be group-writable"
    exit 1
  fi
fi

# Check setgid bit
if ! stat -c '%A' /opt/project | grep -q 's\|S'; then
  PERMS=$(stat -c '%a' /opt/project)
  if [ "${#PERMS}" -lt 4 ] || [ "${PERMS:0:1}" -lt 2 ] 2>/dev/null; then
    echo "FAIL: /opt/project should have setgid bit set"
    exit 1
  fi
fi

echo "PASS: Users, groups, and shared directory are properly configured"
exit 0
