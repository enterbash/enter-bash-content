# Solution: Ansible Inventory Groups

## What the validator checks

- Inventory has parse errors
- webservers group missing
- dbservers group missing
- production group missing
- Playbook had failures
- env_info.txt not created
- env variable not set
- deploy_user variable not set

## Solution

Fix the inventory syntax errors:

```ini
[webservers]
localhost ansible_connection=local   # = required, not a space

[dbservers]
localhost ansible_connection=local

[production:children]               # :children not :child
webservers
dbservers

[production:vars]                   # :vars not :var
env=production
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
