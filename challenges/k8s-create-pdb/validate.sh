#!/bin/bash

if [ ! -f ~/pdb.yaml ] || [ ! -f ~/deployment.yaml ]; then
  echo "FAIL: pdb.yaml or deployment.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=client -f ~/pdb.yaml 2>/dev/null; then
  echo "FAIL: pdb.yaml does not pass validation"
  exit 1
fi

if ! kubectl apply --dry-run=client -f ~/deployment.yaml 2>/dev/null; then
  echo "FAIL: deployment.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'kind: PodDisruptionBudget' ~/pdb.yaml; then
  echo "FAIL: kind should be PodDisruptionBudget"
  exit 1
fi

if ! grep -q 'name: web-pdb' ~/pdb.yaml; then
  echo "FAIL: PDB name should be web-pdb"
  exit 1
fi

if ! grep -q 'minAvailable: 2' ~/pdb.yaml; then
  echo "FAIL: minAvailable should be 2"
  exit 1
fi

if ! grep -q 'app: web' ~/pdb.yaml; then
  echo "FAIL: PDB selector should match app: web"
  exit 1
fi

if ! grep -q 'replicas: 4' ~/deployment.yaml; then
  echo "FAIL: Deployment replicas should be 4"
  exit 1
fi

echo "PASS: PodDisruptionBudget is correctly configured"
exit 0
