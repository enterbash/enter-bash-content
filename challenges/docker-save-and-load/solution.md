# Solution: Save and Load Docker Images

## What the validator checks

- ~/savetest.tar not found
- restored:v1 image not found
- restored image doesn't produce expected output

## Solution

```bash
# Tag the image
docker tag alpine:latest savetest:v1

# Save to tar
docker save savetest:v1 -o ~/savetest.tar

# Remove original
docker rmi savetest:v1

# Load from tar
docker load -i ~/savetest.tar

# Tag as restored
docker tag savetest:v1 restored:v1

# Verify
docker run --rm restored:v1 echo "restored OK"
```
