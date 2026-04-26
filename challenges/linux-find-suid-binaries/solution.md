# Solution: Find SUID Binaries

## What the validator checks

- **Check that suspicious SUID binaries have been fixed**: /tmp/backdoor still has SUID bit
- /home/runner/.hidden-shell still has SUID bit
- /var/tmp/tools/rootcat still has SUID bit
- **Check audit report exists**: Audit report /home/runner/suid-audit.txt not found
- **Check report has some content**: Audit report is empty

## Solution

```bash
# Find all SUID binaries
find / -perm -4000 -type f 2>/dev/null

# Remove SUID bit from suspicious ones (not system binaries like sudo/passwd)
chmod u-s /path/to/suspicious/binary

# Write audit report
find / -perm -4000 -type f 2>/dev/null > /home/runner/suid-audit.txt
echo "Audit complete" >> /home/runner/suid-audit.txt
```

`-perm -4000` matches files with the SUID bit set. `chmod u-s` removes it.
