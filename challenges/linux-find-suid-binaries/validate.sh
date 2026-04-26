#!/bin/bash

# Check that suspicious SUID binaries have been fixed
if [ -f /tmp/backdoor ] && [ -u /tmp/backdoor ]; then
  echo "FAIL: /tmp/backdoor still has SUID bit"
  exit 1
fi

if [ -f /home/runner/.hidden-shell ] && [ -u /home/runner/.hidden-shell ]; then
  echo "FAIL: /home/runner/.hidden-shell still has SUID bit"
  exit 1
fi

if [ -f /var/tmp/tools/rootcat ] && [ -u /var/tmp/tools/rootcat ]; then
  echo "FAIL: /var/tmp/tools/rootcat still has SUID bit"
  exit 1
fi

# Check audit report exists
if [ ! -f /home/runner/suid-audit.txt ]; then
  echo "FAIL: Audit report /home/runner/suid-audit.txt not found"
  exit 1
fi

# Check report has some content
if [ ! -s /home/runner/suid-audit.txt ]; then
  echo "FAIL: Audit report is empty"
  exit 1
fi

echo "PASS: All suspicious SUID binaries neutralized and audit report created"
exit 0
