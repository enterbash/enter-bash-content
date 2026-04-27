#!/bin/bash

# Check pipeline.sh exists and is executable
if [ ! -x ~/pipeline/pipeline.sh ]; then
  echo "FAIL: ~/pipeline/pipeline.sh not found or not executable"
  exit 1
fi

# Check test script was fixed (should source app.sh)
if ! grep -q 'source\|^\.' ~/pipeline/tests/test_app.sh; then
  echo "FAIL: test_app.sh doesn't source app.sh — add 'source ./app.sh' or '. ./app.sh' at the top"
  exit 1
fi

# Run the tests to verify they pass
cd ~/pipeline
set +e
TEST_OUT=$(bash tests/test_app.sh 2>&1)
TEST_RC=$?
set -e
if [ "$TEST_RC" -ne 0 ]; then
  echo "FAIL: Tests did not pass:"
  echo "$TEST_OUT" | tail -5
  exit 1
fi

# Run the pipeline
set +e
PIPE_OUT=$(bash pipeline.sh 2>&1)
PIPE_RC=$?
set -e
if [ "$PIPE_RC" -ne 0 ]; then
  echo "FAIL: pipeline.sh exited with error:"
  echo "$PIPE_OUT" | tail -5
  exit 1
fi

# Check build artifact exists
if [ ! -f ~/pipeline/build/app.sh ]; then
  echo "FAIL: ~/pipeline/build/app.sh not found — build stage didn't create it"
  exit 1
fi

# Check deployed files exist
if [ ! -f ~/deployed/app.sh ]; then
  echo "FAIL: ~/deployed/app.sh not found — deploy stage didn't copy it"
  exit 1
fi

if [ ! -f ~/deployed/version.txt ]; then
  echo "FAIL: ~/deployed/version.txt not found — deploy stage didn't create it"
  exit 1
fi

# Check version.txt has a date
if ! grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}' ~/deployed/version.txt; then
  echo "FAIL: ~/deployed/version.txt doesn't contain a date (expected YYYY-MM-DD format)"
  exit 1
fi

echo "PASS: CI/CD pipeline built and executed successfully"
exit 0
