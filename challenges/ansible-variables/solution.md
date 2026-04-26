# Solution: Ansible Variables

## What the validator checks

- Playbook had failures
- /tmp/app/config.ini not created
- app_name variable not used
- app_port variable not used

## Solution

Define variables in `vars:` and reference them with `{{ var_name }}`.

```yaml
- name: Configure application
  hosts: local
  become: yes
  vars:
    app_name: myapp
    app_port: 8080
    app_env: production
    log_directory: /var/log/myapp
  tasks:
    - name: Create log directory
      file:
        path: "{{ log_directory }}"
        state: directory
    - name: Create config
      copy:
        content: |
          [app]
          name={{ app_name }}
          port={{ app_port }}
          env={{ app_env }}
        dest: "{{ log_directory }}/config.ini"
```

Paths containing variables must be quoted.

```bash
ansible-playbook -i inventory.ini playbook.yml
```
