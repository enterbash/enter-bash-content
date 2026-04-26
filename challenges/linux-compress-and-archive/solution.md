# Solution: Compress and Archive Files

## Approach

Create a gzip-compressed tar archive of the webapp directory.

```bash
tar -czf /home/runner/webapp-backup.tar.gz -C /home/runner webapp/

# Verify contents
tar -tzf /home/runner/webapp-backup.tar.gz
```

## Why this works

`-c` creates, `-z` gzip-compresses, `-f` specifies the output file. `-C /home/runner` changes to that directory first so paths inside the archive are relative (e.g. `webapp/public/index.html` not `/home/runner/webapp/...`).
