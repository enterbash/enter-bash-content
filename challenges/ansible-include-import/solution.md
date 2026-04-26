# Solution: Ansible Include and Import Tasks

## Approach

Replace deprecated `include:` with `include_tasks:` or `import_tasks:`.

```yaml
- name: Deploy application
  hosts: local
  become: yes
  tasks:
    - import_tasks: tasks/setup_dirs.yml    # static — loaded at parse time
    - include_tasks: tasks/deploy_app.yml   # dynamic — loaded at runtime
```

**Difference:**
- `import_tasks:` — static, processed at playbook parse time. Tags and conditions apply to all tasks inside.
- `include_tasks:` — dynamic, processed at runtime. Can use variables in the filename.

## Why this works

`include:` was deprecated in Ansible 2.4 and removed in 2.8. Use `import_tasks:` for static includes (most common) or `include_tasks:` when you need dynamic file names.
