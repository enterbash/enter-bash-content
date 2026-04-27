# Solution: Build a CI/CD Pipeline

## What the validator checks

- **Check pipeline.sh exists and is executable**: ~/pipeline/pipeline.sh not found or not executable
- **Check test script was fixed (should source app.sh)**: test_app.sh doesn't source app.sh — add 'source ./app.sh' or '. ./app.sh' at the top
- Tests did not pass:
- pipeline.sh exited with error:
- **Check build artifact exists**: ~/pipeline/build/app.sh not found — build stage didn't create it
- **Check deployed files exist**: ~/deployed/app.sh not found — deploy stage didn't copy it
- ~/deployed/version.txt not found — deploy stage didn't create it
- **Check version.txt has a date**: ~/deployed/version.txt doesn't contain a date (expected YYYY-MM-DD format)

## Solution

```bash
# Fix: ~/pipeline/pipeline.sh not found or not executable
# Fix: test_app.sh doesn't source app.sh — add 'source ./app.sh' or '. ./app.sh' at the top
# Fix: Tests did not pass:
# Fix: pipeline.sh exited with error:
# Fix: ~/pipeline/build/app.sh not found — build stage didn't create it
# Fix: ~/deployed/app.sh not found — deploy stage didn't copy it
# Fix: ~/deployed/version.txt not found — deploy stage didn't create it
# Fix: ~/deployed/version.txt doesn't contain a date (expected YYYY-MM-DD format)
```

**File content requirements:**
- `~/pipeline/tests/test_app.sh` must contain text matching `source\|^\.`
- `~/deployed/version.txt` must match pattern `[0-9]{4}-[0-9]{2}-[0-9]{2}`
