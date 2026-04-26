# Solution: Ansible Lookup Plugins

## Approach

Use lookup plugins to read data from external sources like files or environment variables.

```yaml
- name: Use lookup plugins
  hosts: local
  become: yes

  tasks:
    - name: Read from file
      copy:
        content: "{{ lookup('file', '/etc/hostname') }}"
        dest: /tmp/hostname.txt

    - name: Read environment variable
      copy:
        content: "path={{ lookup('env', 'PATH') }}\n"
        dest: /tmp/env_info.txt

    - name: Generate password
      copy:
        content: "token={{ lookup('password', '/tmp/token length=16 chars=ascii_letters,digits') }}\n"
        dest: /tmp/token.txt
```

## Why this works

Lookup plugins run on the control node (not the target). `lookup('file', path)` reads a local file. `lookup('env', var)` reads an environment variable.
