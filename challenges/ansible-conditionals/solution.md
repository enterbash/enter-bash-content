# Solution: Ansible Conditionals

## Approach

Use `when:` to conditionally execute tasks based on variable values.

```yaml
- name: Configure based on environment
  hosts: local
  become: yes
  vars:
    app_port: 8080
    app_env: production

  tasks:
    - name: Create production config
      copy:
        content: "env=production\n"
        dest: /tmp/prod_config.txt
      when: app_env == "production"

    - name: Create port info
      copy:
        content: "port={{ app_port }}\n"
        dest: /tmp/port_info.txt
      when: app_port > 1024

    - name: Create logging config
      copy:
        content: "log_level=INFO\n"
        dest: /tmp/logging.conf
      when: app_env != "development"
```

## Why this works

`when:` accepts Jinja2 expressions. Note: no `{{ }}` needed in `when:` — Ansible evaluates it as an expression automatically.
