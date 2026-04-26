# Solution: Ansible Roles

## Approach

Create a role directory structure and call it from the playbook.

```bash
# Create role structure
mkdir -p ~/ansible-project/roles/webserver/{tasks,handlers,defaults,files}

# roles/webserver/tasks/main.yml
cat > ~/ansible-project/roles/webserver/tasks/main.yml << 'EOF'
- name: Create web directory
  file:
    path: /tmp/webserver
    state: directory

- name: Deploy index
  copy:
    content: "<h1>Hello from role</h1>"
    dest: /tmp/webserver/index.html
EOF

# roles/webserver/defaults/main.yml
cat > ~/ansible-project/roles/webserver/defaults/main.yml << 'EOF'
web_port: 80
web_root: /tmp/webserver
EOF
```

Playbook:
```yaml
- name: Deploy web server
  hosts: local
  become: yes
  roles:
    - webserver
```

## Why this works

Roles provide a structured way to organize tasks, handlers, variables, and files. Ansible automatically loads `tasks/main.yml` when a role is applied.
