#!/bin/bash
set -e

IMAGES=$(docker images --format '{{.Repository}}:{{.Tag}}')

if ! echo "$IMAGES" | grep -q '^tagme:v1.0$'; then
  echo "FAIL: tagme:v1.0 not found"
  exit 1
fi

if ! echo "$IMAGES" | grep -q '^tagme:v1.0.0$'; then
  echo "FAIL: tagme:v1.0.0 not found"
  exit 1
fi

if ! echo "$IMAGES" | grep -q '^myregistry/tagme:v1.0$'; then
  echo "FAIL: myregistry/tagme:v1.0 not found"
  exit 1
fi

echo "PASS: all tags created correctly"
exit 0
