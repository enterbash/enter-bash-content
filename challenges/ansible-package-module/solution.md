# Solution: Ansible Package Module

## What the validator checks

- Playbook had failures
- curl not installed
- jq not installed
- tree not installed
- verification file not created

## Solution

Use `state: present` (not `state: installed`) and `name:` (not `pkg:`).

```yaml
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Install packages
      apt:
        name: "{{ item }}"
        state: present      # valid: present, absent, latest
      loop:
        - curl
        - jq
        - tree              # use name:, not pkg:
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
