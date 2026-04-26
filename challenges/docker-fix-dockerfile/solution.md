# Solution: Fix a Broken Dockerfile

## What the validator checks

- webapp:latest image not found

## Solution

```bash
# Read the broken Dockerfile
cat ~/webapp/Dockerfile

# Check the build error
docker build -t webapp:latest ~/webapp/ 2>&1 | head -20
```

Common Dockerfile errors to fix:
- Typo in base image name (e.g. `ngix` → `nginx`)
- Missing `COPY` before `RUN`
- Wrong `EXPOSE` port
- `CMD` using wrong syntax

After fixing:
```bash
docker build -t webapp:latest ~/webapp/
```

The validator checks that `webapp:latest` exists.
