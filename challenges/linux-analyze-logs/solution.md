# Solution: Analyze System Logs

## What the validator checks

- **Check report exists**: /home/runner/log-analysis.txt not found
- **Check report is not empty**: Report is empty
- **Check report mentions ERROR count**: Report does not mention ERROR
- **Check report contains some numbers (counts)**: Report does not contain any counts
- **Check report mentions the most common error (database connection)**: Report does not identify the most common error (database connection timeout)

## Solution

```bash
# Count log levels
ERROR_COUNT=$(grep -c 'ERROR' /var/log/webapp/app.log)
WARN_COUNT=$(grep -c 'WARN' /var/log/webapp/app.log)
INFO_COUNT=$(grep -c 'INFO' /var/log/webapp/app.log)

# Find most common error message
COMMON_ERROR=$(grep 'ERROR' /var/log/webapp/app.log \
  | sort | uniq -c | sort -rn | head -1 \
  | sed 's/^ *[0-9]* *//')

# Write the report (must contain "ERROR", a count, and "database"/"connection"/"timeout")
cat > /home/runner/log-analysis.txt << EOF
ERROR count: $ERROR_COUNT
WARN count: $WARN_COUNT
INFO count: $INFO_COUNT
Most common error: $COMMON_ERROR
EOF
```

The validator checks that `/home/runner/log-analysis.txt`:
1. Exists and is non-empty
2. Contains the word `ERROR`
3. Contains at least one number
4. Contains `database`, `connection`, or `timeout` (the most common error in the log)
