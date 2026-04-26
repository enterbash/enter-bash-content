# Solution: Fix Ansible YAML Syntax

## What the validator checks

- Playbook had failures
- /tmp/myproject directory not created
- config.txt not created
- logs directory not created

## Solution

Fix the three YAML syntax errors in the playbook:

1. **Extra space before `mode:`** — indentation must be consistent
2. **Missing colon after task name** — `- name Create` → `- name: Create`
3. **Wrong indentation on module parameters** — must be indented under the module name

```yaml
    - name: Create log directory
      file:
        path: /tmp/myproject/logs   # indented under file:, not at same level
        state: directory
        mode: "0755"
```

Run `ansible-playbook --syntax-check` to see the exact line numbers.

```bash
ansible-playbook -i inventory.ini playbook.yml
```
