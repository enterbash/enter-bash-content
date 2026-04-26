# Solution: Find SUID Binaries

## Approach

Find SUID binaries, identify suspicious ones, remove the SUID bit, and write an audit report.

```bash
# Find all SUID binaries
find / -perm -4000 -type f 2>/dev/null

# Remove SUID bit from suspicious binaries (not system ones like sudo, passwd)
chmod u-s /path/to/suspicious/binary

# Write audit report
find / -perm -4000 -type f 2>/dev/null > /home/runner/suid-audit.txt
echo "Suspicious SUID binaries neutralized" >> /home/runner/suid-audit.txt
```

## Why this works

`-perm -4000` matches files with the SUID bit set. `chmod u-s` removes it. Legitimate system SUID binaries (sudo, passwd, ping) should be left alone.
