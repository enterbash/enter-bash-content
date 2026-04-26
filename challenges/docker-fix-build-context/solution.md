# Solution: Fix Build Context Issues

## Approach

Create a `.dockerignore` file to exclude large directories from the build context.

```bash
cat > ~/bigproject/.dockerignore << 'EOF'
data/
node_modules/
*.log
.git/
tmp/
EOF

# Build the optimized image
docker build -t slim-project:latest ~/bigproject/

# Verify excluded files aren't in the image
docker run --rm slim-project:latest ls /app/
```

## Why this works

`.dockerignore` works like `.gitignore` — it prevents files from being sent to the Docker daemon as build context. Large `node_modules/` or `data/` directories can make builds slow and images bloated.
