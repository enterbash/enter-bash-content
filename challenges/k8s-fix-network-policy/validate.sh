#!/bin/bash

if [ ! -f ~/netpol.yaml ]; then
  echo "FAIL: ~/netpol.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=server -f ~/netpol.yaml 2>/dev/null; then
  echo "FAIL: netpol.yaml does not pass validation"
  exit 1
fi

# podSelector should target app: api
if ! grep -A2 'podSelector:' ~/netpol.yaml | head -3 | grep -q 'app: api'; then
  echo "FAIL: podSelector should target app: api"
  exit 1
fi

# ingress from should be app: frontend
if ! grep -q 'app: frontend' ~/netpol.yaml; then
  echo "FAIL: ingress should allow from app: frontend"
  exit 1
fi

# port should be 8080
if ! grep -q 'port: 8080' ~/netpol.yaml; then
  echo "FAIL: ingress port should be 8080"
  exit 1
fi

# Should have Egress in policyTypes
if ! grep -q 'Egress' ~/netpol.yaml; then
  echo "FAIL: policyTypes should include Egress"
  exit 1
fi

# Should have egress section (allow all = empty egress list item)
if ! grep -q 'egress:' ~/netpol.yaml; then
  echo "FAIL: egress section is required to allow all egress"
  exit 1
fi

echo "PASS: NetworkPolicy is correctly configured"
exit 0
