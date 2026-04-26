# Solution: Ansible Facts

## What the validator checks

- Playbook had failures
- /tmp/system_info.txt not created
- OS line missing
- Hostname line missing
- Architecture line missing
- Unresolved variables in output

## Solution

Ansible auto-collects facts at play start. Reference them directly as variables.

```yaml
  tasks:
    - name: Write system info
      copy:
        content: |
          hostname={{ ansible_hostname }}
          os={{ ansible_distribution }} {{ ansible_distribution_version }}
          kernel={{ ansible_kernel }}
          memory_mb={{ ansible_memtotal_mb }}
        dest: /tmp/system_info.txt
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
