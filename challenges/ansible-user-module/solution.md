# Solution: Ansible User Module

## What the validator checks

- Playbook had failures
- deploy user not created
- appuser user not created
- deploy shell is $SHELL, expected /bin/bash
- appuser not in deploy group
- users_created.txt not created

## Solution

Use `name:` (not `username:`) for the user module.

```yaml
  tasks:
    - name: Create group
      group:
        name: deploy
        state: present

    - name: Create user
      user:
        name: deploy        # correct param — not "username:"
        shell: /bin/bash
        group: deploy
        create_home: yes
        state: present
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
