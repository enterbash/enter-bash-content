# Solution: Fix SELinux File Contexts

## What the validator checks

- **Check .contexts file exists**: /srv/www/html/.contexts not found
- **Check .contexts has content**: .contexts file does not reference httpd_sys_content_t
- $f does not have correct selinux_type attribute (got: $ATTR)
- **Check fix log exists**: /home/runner/selinux-fix.log not found
- selinux-fix.log is empty

## Solution

```bash
sudo chcon -R -t httpd_sys_content_t /srv/www/html/
# or restore to policy default:
sudo restorecon -Rv /srv/www/html/
ls -Z /srv/www/html/
```
