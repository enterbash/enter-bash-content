#!/bin/bash
set -e

# Check .contexts file exists
if [ ! -f /srv/www/html/.contexts ]; then
  echo "FAIL: /srv/www/html/.contexts not found"
  exit 1
fi

# Check .contexts has content
if ! grep -q 'httpd_sys_content_t' /srv/www/html/.contexts; then
  echo "FAIL: .contexts file does not reference httpd_sys_content_t"
  exit 1
fi

# Check extended attributes are set correctly
for f in index.html style.css app.js; do
  ATTR=$(getfattr -n user.selinux_type --only-values "/srv/www/html/$f" 2>/dev/null || true)
  if [ "$ATTR" != "httpd_sys_content_t" ]; then
    echo "FAIL: $f does not have correct selinux_type attribute (got: $ATTR)"
    exit 1
  fi
done

# Check fix log exists
if [ ! -f /home/runner/selinux-fix.log ]; then
  echo "FAIL: /home/runner/selinux-fix.log not found"
  exit 1
fi

if [ ! -s /home/runner/selinux-fix.log ]; then
  echo "FAIL: selinux-fix.log is empty"
  exit 1
fi

echo "PASS: SELinux contexts are correctly set"
exit 0
