# Solution: Ansible Assert Module

## Approach

Use the `assert` module to validate conditions and fail with clear messages.

```yaml
- name: Validate system requirements
  hosts: local
  become: yes

  tasks:
    - name: Check memory is sufficient
      assert:
        that:
          - ansible_memtotal_mb >= 512
        fail_msg: "Need at least 512MB RAM, got {{ ansible_memtotal_mb }}MB"
        success_msg: "Memory check passed: {{ ansible_memtotal_mb }}MB"

    - name: Check OS is Ubuntu
      assert:
        that:
          - ansible_distribution == "Ubuntu"
        fail_msg: "This playbook requires Ubuntu"

    - name: Write results
      copy:
        content: "assertions passed\nmemory={{ ansible_memtotal_mb }}MB\n"
        dest: /tmp/assert_results.txt
```

## Why this works

`assert` fails the play immediately if conditions aren't met, with a clear message. `that:` is a list of Jinja2 expressions that must all be true.
