# Solution: Ansible Include and Import Tasks

## What the validator checks

- Playbook had failures
- /tmp/include-test not created
- logs directory not created
- app.conf not created
- log.conf not created

## Solution

Replace deprecated `include:` with `import_tasks:` or `include_tasks:`.

```yaml
  tasks:
    - import_tasks: tasks/setup_dirs.yml    # static — loaded at parse time
    - include_tasks: tasks/deploy_app.yml   # dynamic — loaded at runtime
```

`include:` was removed in Ansible 2.8. Use `import_tasks:` for most cases.

```bash
ansible-playbook -i inventory.ini playbook.yml
```
