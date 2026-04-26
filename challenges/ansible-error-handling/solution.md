# Solution: Ansible Error Handling

## What the validator checks

- Playbook had failures
- rescue did not run — error.log missing
- rescue did not create data.txt
- always did not run — done.txt missing
- block continued after failure
- error.log content wrong
- done.txt content wrong

## Solution

Use `block`/`rescue`/`always` for structured error handling.

```yaml
  tasks:
    - name: Create work directory
      file:
        path: /tmp/errorhandling
        state: directory

    - block:
        - name: Attempt risky operation
          command: cat /tmp/nonexistent_file_12345.txt

      rescue:
        - name: Handle the error
          copy:
            content: "Error caught: file not found\n"
            dest: /tmp/errorhandling/error.log
        - name: Create fallback data
          copy:
            content: "fallback data\n"
            dest: /tmp/errorhandling/data.txt

      always:
        - name: Write completion marker
          copy:
            content: "completed\n"
            dest: /tmp/errorhandling/done.txt
```

`rescue` runs if any `block` task fails. `always` runs regardless.

```bash
ansible-playbook -i inventory.ini playbook.yml
```
