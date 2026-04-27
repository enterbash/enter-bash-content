#!/bin/bash
# Test script — has issues the user needs to fix
# BUG: doesn't source app.sh, so functions aren't available

PASS=0
FAIL=0

# Test greet function
RESULT=$(greet "Tester")
if [ "$RESULT" = "Hello, Tester!" ]; then
  echo "PASS: greet returns correct output"
  PASS=$((PASS + 1))
else
  echo "FAIL: greet expected 'Hello, Tester!' got '$RESULT'"
  FAIL=$((FAIL + 1))
fi

# Test add function
RESULT=$(add 5 3)
if [ "$RESULT" = "8" ]; then
  echo "PASS: add returns correct sum"
  PASS=$((PASS + 1))
else
  echo "FAIL: add expected '8' got '$RESULT'"
  FAIL=$((FAIL + 1))
fi

# Test version function
RESULT=$(version)
if [ "$RESULT" = "1.0.0" ]; then
  echo "PASS: version returns 1.0.0"
  PASS=$((PASS + 1))
else
  echo "FAIL: version expected '1.0.0' got '$RESULT'"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
