# Solution: Ansible Roles

## What the validator checks

- Playbook had failures
- roles/webapp/tasks/ missing
- roles/webapp/tasks/main.yml missing
- roles/webapp/defaults/main.yml missing
- /tmp/webapp not created
- /tmp/webapp/config.txt not created
- default port not in config

## Solution

Create the role directory structure and call it from the playbook.

```bash
mkdir -p ~/ansible-project/roles/webserver/{tasks,defaults}
```

```yaml
# roles/webserver/tasks/main.yml
- name: Create web directory
  file:
    path: /tmp/webserver
    state: directory
- name: Deploy index
  copy:
    content: "<h1>Hello</h1>"
    dest: /tmp/webserver/index.html
```

```yaml
# playbook.yml
- name: Deploy
  hosts: local
  become: yes
  roles:
    - webserver
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
