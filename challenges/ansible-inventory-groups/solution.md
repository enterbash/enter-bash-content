# Solution: Ansible Inventory Groups

## Approach

Fix the inventory syntax and use group variables correctly.

```ini
[webservers]
localhost ansible_connection=local

[dbservers]
localhost ansible_connection=local

[production:children]
webservers
dbservers

[production:vars]
env=production
deploy_user=deploy
```

Key fixes:
- `ansible_connection local` → `ansible_connection=local` (needs `=`)
- `[production:child]` → `[production:children]`
- `[production:var]` → `[production:vars]`

## Why this works

Inventory group syntax requires `=` for variable assignments. `:children` defines a group of groups. `:vars` defines variables for all hosts in a group.
