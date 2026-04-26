# Solution: Ansible Blockinfile

## Approach

Use `blockinfile` to insert or update a block of text in a file.

```yaml
- name: Manage config blocks
  hosts: local
  become: yes

  tasks:
    - name: Create config file
      file:
        path: /tmp/nginx.conf
        state: touch

    - name: Add server block
      blockinfile:
        path: /tmp/nginx.conf
        marker: "# {mark} ANSIBLE MANAGED BLOCK"
        block: |
          server {
              listen 80;
              server_name example.com;
              root /var/www/html;
          }

    - name: Add upstream block
      blockinfile:
        path: /tmp/nginx.conf
        marker: "# {mark} UPSTREAM BLOCK"
        block: |
          upstream backend {
              server 127.0.0.1:8080;
          }
```

## Why this works

`blockinfile` wraps the block with marker comments so it can be identified and updated on subsequent runs. `{mark}` is replaced with `BEGIN` and `END`.
