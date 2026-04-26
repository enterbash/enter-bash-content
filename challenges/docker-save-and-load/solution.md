# Solution: Save and Load Docker Images

## Approach

Save an image to a tar file and load it back with a new tag.

```bash
# Build or pull the source image
docker pull alpine:latest
docker tag alpine:latest savetest:v1

# Save to tar
docker save savetest:v1 -o ~/savetest.tar

# Remove original (simulate transfer)
docker rmi savetest:v1

# Load from tar
docker load -i ~/savetest.tar

# Tag as restored
docker tag savetest:v1 restored:v1

# Verify it runs
docker run --rm restored:v1 echo "save test"
```

## Why this works

`docker save` exports an image with all its layers and metadata. `docker load` imports it. This is how you transfer images without a registry.
