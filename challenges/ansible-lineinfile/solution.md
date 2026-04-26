# Solution: Ansible Lineinfile

## What the validator checks

- Playbook had failures
- port not changed to 9090
- debug not set to true
- log_level not set to info
- environment line not added

## Solution

Use `lineinfile` to add or replace specific lines.

```yaml
  tasks:
    - name: Set max connections
      lineinfile:
        path: /tmp/app.conf
        regexp: '^max_connections'
        line: 'max_connections = 100'
        create: yes

    - name: Remove deprecated option
      lineinfile:
        path: /tmp/app.conf
        regexp: '^deprecated_option'
        state: absent
```

`regexp:` matches the line to replace. If no match, `line:` is appended.

```bash
ansible-playbook -i inventory.ini playbook.yml
```
