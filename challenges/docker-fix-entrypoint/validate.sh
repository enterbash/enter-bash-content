#!/bin/bash

if ! docker ps --format '{{.Names}}' | grep -q '^myserver$'; then
  echo "FAIL: myserver container is not running"
  exit 1
fi

echo "PASS: myserver container is running"
exit 0
