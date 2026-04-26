# Solution: Ansible File Module

## What the validator checks

- Playbook had failures
- /tmp/filemod-app directory not created
- data directory not created
- app.log not created
- symlink not created
- /tmp/filemod-app permissions wrong: $PERMS

## Solution

```yaml
# playbook.yml
- name: Solution
  hosts: local
  become: yes
  tasks:
    - name: Create /tmp/filemod-app
      copy:
        content: "solution\n"
        dest: /tmp/filemod-app
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
