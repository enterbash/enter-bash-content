# Solution: Ansible Error Handling

## Approach

Use `block`/`rescue`/`always` for structured error handling.

```yaml
- name: Error handling demo
  hosts: local
  become: yes

  tasks:
    - name: Create work directory
      file:
        path: /tmp/errorhandling
        state: directory

    - block:
        - name: Attempt risky operation
          command: cat /tmp/nonexistent_file_12345.txt
          register: file_content

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

## Why this works

`block` groups tasks. `rescue` runs if any block task fails (like try/catch). `always` runs regardless of success or failure (like finally).
