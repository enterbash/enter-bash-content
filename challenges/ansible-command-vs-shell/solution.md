# Solution: Command vs Shell Module

## What the validator checks

- Playbook had failures
- hostname.txt not created
- disk.txt not created
- summary.txt not created
- hostname not in file
- summary missing user info

## Solution

Use `command:` for simple commands, `shell:` only when you need pipes/redirects.

```yaml
  tasks:
    - name: Get hostname (no shell features needed)
      command: hostname
      register: hostname_out

    - name: Get disk usage with pipe (needs shell)
      shell: df -h | grep -v tmpfs | tail -1
      register: disk_out

    - name: Write summary
      copy:
        content: "hostname={{ hostname_out.stdout }}\n"
        dest: /tmp/cmdshell/summary.txt
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
