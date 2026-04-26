# Solution: Fix SELinux File Contexts

## Approach

Fix the SELinux file contexts using `chcon` or `restorecon`.

```bash
# Check current context
ls -Z /srv/www/html/

# Fix context to match httpd content type
sudo chcon -R -t httpd_sys_content_t /srv/www/html/

# Or restore to default policy context
sudo restorecon -Rv /srv/www/html/

# Verify
ls -Z /srv/www/html/
getfattr -n security.selinux /srv/www/html/index.html
```

## Why this works

SELinux uses file contexts to control access. Web server files need the `httpd_sys_content_t` type for nginx/apache to read them. `chcon` changes context directly; `restorecon` uses the policy database.
