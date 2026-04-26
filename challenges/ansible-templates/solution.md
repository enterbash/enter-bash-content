# Solution: Ansible Templates

## Approach

Use the `template` module with a `.j2` file and fix the Jinja2 syntax errors.

First, fix `config.tftpl` → `templates/app.conf.j2`:
```
# Application Configuration
[general]
name = {{ app_name }}
port = {{ app_port }}
environment = {{ app_env }}

[performance]
max_connections = {{ max_connections }}

[security]
{% if enable_ssl %}
ssl_enabled = true
ssl_cert = /etc/ssl/{{ app_name }}.crt
{% else %}
ssl_enabled = false
{% endif %}
```

Then the playbook:
```yaml
- name: Deploy with templates
  hosts: local
  become: yes
  vars:
    app_name: myapp
    app_port: 8080
    app_env: production
    max_connections: 100
    enable_ssl: false

  tasks:
    - name: Deploy config from template
      template:
        src: app.conf.j2
        dest: /tmp/app.conf
        mode: "0644"
```

## Why this works

The original template had `{{ app_name }` (missing closing brace) and `{% if enable_ssl` (missing closing `%}`). The `template` module processes `.j2` files with Jinja2 and writes the result to the destination.
