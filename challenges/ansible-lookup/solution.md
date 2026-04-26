# Solution: Ansible Lookup Plugins

## What the validator checks

- Playbook had failures
- results.txt not created
- file lookup not working
- env lookup not working

## Solution

Use lookup plugins to read data from external sources.

```yaml
  tasks:
    - name: Read from file
      copy:
        content: "{{ lookup('file', '/etc/hostname') }}"
        dest: /tmp/hostname.txt

    - name: Read env variable
      copy:
        content: "path={{ lookup('env', 'PATH') }}\n"
        dest: /tmp/env_info.txt
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
