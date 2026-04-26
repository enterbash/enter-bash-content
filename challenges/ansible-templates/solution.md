# Solution: Ansible Templates

## What the validator checks

- Playbook had failures
- /tmp/webapp/app.conf not created
- app_name not rendered
- app_port not rendered
- SSL conditional not rendered

## Solution

Fix the Jinja2 syntax errors in `app.conf.j2` and use the `template` module.

Common errors to fix:
- `{{ app_name }` → `{{ app_name }}` (missing closing brace)
- `{% if enable_ssl` → `{% if enable_ssl %}` (missing closing `%}`)

```yaml
  tasks:
    - name: Deploy config from template
      template:
        src: app.conf.j2
        dest: /tmp/app.conf
        mode: "0644"
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
