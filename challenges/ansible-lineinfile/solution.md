# Solution: Ansible Lineinfile

## Approach

Use `lineinfile` to add, modify, or remove specific lines in a file.

```yaml
- name: Manage config lines
  hosts: local
  become: yes

  tasks:
    - name: Ensure config file exists
      file:
        path: /tmp/app.conf
        state: touch

    - name: Set max connections
      lineinfile:
        path: /tmp/app.conf
        regexp: '^max_connections'
        line: 'max_connections = 100'

    - name: Add debug mode
      lineinfile:
        path: /tmp/app.conf
        line: 'debug = false'
        create: yes

    - name: Remove deprecated option
      lineinfile:
        path: /tmp/app.conf
        regexp: '^deprecated_option'
        state: absent
```

## Why this works

`regexp:` matches the line to replace. If no match, the `line:` is appended. `state: absent` removes matching lines. `create: yes` creates the file if it doesn't exist.
