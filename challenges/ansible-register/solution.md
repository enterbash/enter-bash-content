# Solution: Ansible Register and Debug

## What the validator checks

- Playbook had failures
- register_output.txt not created
- Raw register dict in output — use .stdout
- hostname not captured correctly

## Solution

Use `register:` to capture task output. Access `.stdout` for command output.

```yaml
  tasks:
    - name: Get hostname
      command: hostname
      register: hostname_result

    - name: Write report
      copy:
        content: "hostname={{ hostname_result.stdout }}\n"
        dest: /tmp/system_report.txt
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
