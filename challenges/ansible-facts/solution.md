# Solution: Ansible Facts

## Approach

Use `ansible_facts` to access system information gathered automatically.

```yaml
- name: Gather system info
  hosts: local
  become: yes

  tasks:
    - name: Write system info
      copy:
        content: |
          hostname={{ ansible_hostname }}
          os={{ ansible_distribution }} {{ ansible_distribution_version }}
          kernel={{ ansible_kernel }}
          memory_mb={{ ansible_memtotal_mb }}
          cpu_count={{ ansible_processor_vcpus }}
        dest: /tmp/system_info.txt
```

## Why this works

Ansible automatically runs the `setup` module at the start of each play, populating `ansible_facts`. Access them directly as variables (e.g. `ansible_hostname`) or via `ansible_facts['hostname']`.
