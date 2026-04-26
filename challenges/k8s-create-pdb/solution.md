# Solution: Create a PodDisruptionBudget

## What the validator checks

- pdb.yaml or deployment.yaml not found
- pdb.yaml does not pass validation
- deployment.yaml does not pass validation
- kind should be PodDisruptionBudget
- PDB name should be web-pdb
- minAvailable should be 2
- PDB selector should match app: web
- Deployment replicas should be 4

## Solution

```yaml
# ~/pdb.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: web-app
```
