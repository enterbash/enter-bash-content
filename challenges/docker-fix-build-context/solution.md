# Solution: Fix Build Context Issues

## What the validator checks

- slim-project:latest image not found
- .dockerignore not found
- data/ directory should not be in the image
- node_modules/ should not be in the image
- *.log files should not be in the image

## Solution

```bash
cat > ~/bigproject/.dockerignore << 'EOF'
data/
node_modules/
*.log
.git/
tmp/
EOF

docker build -t slim-project:latest ~/bigproject/
```

`.dockerignore` prevents large directories from being sent to the Docker daemon.
