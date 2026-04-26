# Solution: Tag Docker Images

## Approach

Build an image and apply multiple tags to it.

```bash
# Build the base image
docker build -t tagme:v1.0 ~/myapp/

# Add additional tags (all point to same image ID)
docker tag tagme:v1.0 tagme:v1.0.0
docker tag tagme:v1.0 myregistry/tagme:v1.0

# Verify all tags exist
docker images | grep tagme
```

## Why this works

`docker tag` creates an alias — all tags point to the same image layers. No data is duplicated. This is how you prepare an image for pushing to different registries.
