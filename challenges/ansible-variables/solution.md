# Solution: Ansible Variables

## Approach

Define variables in `vars:` and reference them with `{{ var_name }}` syntax.

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
    - name: Create app directory
      file:
        path: "{{ log_directory }}"
        state: directory

    - name: Create config file
      copy:
        content: |
          [application]
          name={{ app_name }}
          port={{ app_port }}
          env={{ app_env }}
          log_dir={{ log_directory }}
        dest: "{{ log_directory }}/config.ini"
```

## Why this works

Variables defined in `vars:` are scoped to the play. Jinja2 `{{ }}` syntax interpolates them. Paths containing variables must be quoted.
