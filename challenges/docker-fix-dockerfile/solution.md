# Solution: Fix a Broken Dockerfile

## Approach

Fix the errors in the Dockerfile and rebuild.

```bash
cat ~/webapp/Dockerfile  # read the broken file

# Common fixes:
# - Wrong base image name (typo)
# - Missing COPY before RUN
# - Wrong EXPOSE port
# - CMD using wrong syntax

docker build -t webapp:latest ~/webapp/
```

## Why this works

Read the build error carefully — Docker reports the exact line that failed. Fix the syntax, rebuild, and verify the image exists.
