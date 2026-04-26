# Solution: Command vs Shell Module

## Approach

Use `command:` for simple commands and `shell:` only when you need shell features (pipes, redirects, globs).

```yaml
- name: Command vs Shell demo
  hosts: local
  become: yes

  tasks:
    - name: Get hostname (use command — no shell features needed)
      command: hostname
      register: hostname_out

    - name: Write hostname
      copy:
        content: "{{ hostname_out.stdout }}\n"
        dest: /tmp/cmdshell/hostname.txt

    - name: Get disk usage with pipe (must use shell)
      shell: df -h | grep -v tmpfs | tail -1
      register: disk_out

    - name: Write disk info
      copy:
        content: "{{ disk_out.stdout }}\n"
        dest: /tmp/cmdshell/disk.txt

    - name: Write summary using shell redirect
      shell: echo "hostname={{ hostname_out.stdout }}" > /tmp/cmdshell/summary.txt
```

## Why this works

`command:` is safer — it doesn't invoke a shell, so no injection risk. `shell:` is needed for pipes (`|`), redirects (`>`), and shell builtins. Prefer `command:` when possible.
