# Solution: Ansible Blockinfile

## What the validator checks

- Playbook had failures
- upstream block not added
- backend server not in config
- server block not added
- proxy_pass not in config
- marker lines missing

## Solution

Use `blockinfile` to insert a block of text identified by marker comments.

```yaml
  tasks:
    - name: Add server block
      blockinfile:
        path: /tmp/nginx.conf
        marker: "# {mark} ANSIBLE MANAGED BLOCK"
        block: |
          server {
              listen 80;
              server_name example.com;
          }
        create: yes
```

`{mark}` is replaced with `BEGIN` and `END` in the marker comments.

```bash
ansible-playbook -i inventory.ini playbook.yml
```
