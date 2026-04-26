# Solution: Fix Ansible YAML Syntax

## Approach

Fix the three YAML syntax errors in the playbook.

**Error 1:** Extra indentation on `mode:`
```yaml
# Wrong:
        state: directory
         mode: "0755"   # extra space before mode

# Fixed:
        state: directory
        mode: "0755"
```

**Error 2:** Missing colon after task name
```yaml
# Wrong:
    - name Create config file

# Fixed:
    - name: Create config file
```

**Error 3:** Wrong indentation on file module parameters
```yaml
# Wrong:
    - name: Create log directory
      file:
      path: /tmp/myproject/logs   # should be indented under file:

# Fixed:
    - name: Create log directory
      file:
        path: /tmp/myproject/logs
        state: directory
        mode: "0755"
```

## Why this works

YAML is whitespace-sensitive. Each level of nesting requires consistent indentation (2 spaces is standard for Ansible). Task names require a colon after `name`.
