# Solution: Ansible Handlers

## What the validator checks

- Playbook had failures
- No handlers section found
- app.conf not created
- logging.conf not created
- restart handler did not run
- reload handler did not run

## Solution

Handlers only run when notified by a task that reports `changed`.

```yaml
- name: Deploy application
  hosts: local
  become: yes
  handlers:
    - name: restart myapp
      copy:
        content: "restarted\n"
        dest: /tmp/myapp/restart.log
    - name: reload config
      copy:
        content: "reloaded\n"
        dest: /tmp/myapp/reload.log
  tasks:
    - name: Create app directory
      file:
        path: /tmp/myapp
        state: directory
    - name: Deploy app config
      copy:
        content: "app_port=8080\n"
        dest: /tmp/myapp/app.conf
      notify: restart myapp
    - name: Deploy logging config
      copy:
        content: "log_level=INFO\n"
        dest: /tmp/myapp/logging.conf
      notify: reload config
```

The validator checks that `/tmp/myapp/restart.log` and `/tmp/myapp/reload.log` exist — they're created by the handlers.

```bash
ansible-playbook -i inventory.ini playbook.yml
```
