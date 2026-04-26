# Solution: Ansible Conditionals

## What the validator checks

- Playbook had failures
- prod_config.txt not created
- logging.conf not created
- port_info.txt not created

## Solution

Use `when:` with Jinja2 expressions. No `{{ }}` needed inside `when:`.

```yaml
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
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
