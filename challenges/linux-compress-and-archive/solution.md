# Solution: Compress and Archive Files

## What the validator checks

- **Check archive exists**: /home/runner/webapp-backup.tar.gz does not exist
- **Check it's a valid gzip file**: File is not a valid gzip archive
- Archive missing index.html
- Archive missing app.js
- Archive missing settings.json
- Archive missing README.md

## Solution

```bash
# Create a gzip-compressed tar archive of the webapp directory
tar -czf /home/runner/webapp-backup.tar.gz -C /home/runner webapp/

# Verify the archive contains the expected files
tar -tzf /home/runner/webapp-backup.tar.gz
```

`-c` = create, `-z` = gzip compress, `-f` = output file. `-C /home/runner` changes to that directory first so paths inside the archive are relative.
