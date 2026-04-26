# Solution: Ansible Assert Module

## What the validator checks

- Playbook had failures
- assert_results.txt not created
- port validation missing
- name validation missing

## Solution

Use `assert` to validate conditions with clear failure messages.

```yaml
  tasks:
    - name: Check memory
      assert:
        that:
          - ansible_memtotal_mb >= 512
        fail_msg: "Need at least 512MB RAM"
        success_msg: "Memory OK: {{ ansible_memtotal_mb }}MB"

    - name: Write results
      copy:
        content: "assertions passed\nmemory={{ ansible_memtotal_mb }}MB\n"
        dest: /tmp/assert_results.txt
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
