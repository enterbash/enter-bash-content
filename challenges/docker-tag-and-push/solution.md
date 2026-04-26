# Solution: Tag Docker Images

## What the validator checks

- tagme:v1.0 not found
- tagme:v1.0.0 not found
- myregistry/tagme:v1.0 not found

## Solution

```bash
docker build -t tagme:v1.0 ~/myapp/

# Add additional tags (all point to same image ID)
docker tag tagme:v1.0 tagme:v1.0.0
docker tag tagme:v1.0 myregistry/tagme:v1.0

docker images | grep tagme
```
