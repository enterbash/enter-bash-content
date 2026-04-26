# Solution: Ansible Register and Debug

## Approach

Use `register:` to capture task output and reference it in subsequent tasks.

```yaml
- name: Capture command output
  hosts: local
  become: yes

  tasks:
    - name: Get hostname
      command: hostname
      register: hostname_result

    - name: Get kernel version
      command: uname -r
      register: kernel_result

    - name: Write system report
      copy:
        content: |
          hostname={{ hostname_result.stdout }}
          kernel={{ kernel_result.stdout }}
        dest: /tmp/system_report.txt
```

## Why this works

`register:` stores the full task result as a variable. For `command`/`shell` tasks, `.stdout` contains the output, `.rc` the return code, `.stderr` any errors.
