# Solution: Automate a Server Setup with Ansible

## What the validator checks

- roles/webserver/<value>/ directory missing
- roles/webserver/tasks/main.yml not found
- roles/webserver/handlers/main.yml not found
- roles/webserver/defaults/main.yml not found
- roles/webserver/templates/config.j2 not found
- ~/server-setup/playbook.yml not found
- playbook.yml should use the webserver role
- playbook.yml should override app_env to staging
- Playbook had failures
- /tmp/webserver/index.html not found
- index.html should contain 'Enter Bash'
- /tmp/webserver/config.ini not found — use the template module
- config.ini should contain port=8080
- config.ini should contain env=staging (overridden in playbook vars)
- /tmp/webserver/health.sh not found or not executable
- Handler did not run — use 'notify' in a task to trigger the restart handler

## Solution

```yaml
# playbook.yml
- name: Solution
  hosts: local
  become: yes
  tasks:
    - name: Create ~/server-setup/playbook.yml
      copy:
        content: "solution\n"
        dest: ~/server-setup/playbook.yml
    - name: Create /tmp/webserver/index.html
      copy:
        content: "solution\n"
        dest: /tmp/webserver/index.html
    - name: Create /tmp/webserver/config.ini
      copy:
        content: "solution\n"
        dest: /tmp/webserver/config.ini
    - name: Create /tmp/webserver/health.sh
      copy:
        content: "solution\n"
        dest: /tmp/webserver/health.sh
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
