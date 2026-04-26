# Solution: Ansible Loops

## Approach

Use `loop:` to iterate over a list and create multiple resources.

```yaml
- name: Create app configs
  hosts: local
  become: yes
  vars:
    apps:
      - name: web
        port: 8080
      - name: api
        port: 5000
      - name: worker
        port: 9000

  tasks:
    - name: Create app directories
      file:
        path: "/tmp/apps/{{ item.name }}"
        state: directory
      loop: "{{ apps }}"

    - name: Create app configs
      copy:
        content: "app={{ item.name }}\nport={{ item.port }}\n"
        dest: "/tmp/apps/{{ item.name }}/config.txt"
      loop: "{{ apps }}"
```

## Why this works

`loop:` replaces the deprecated `with_items:`. Each iteration exposes the current item as `item`. For dictionaries, access fields with `item.key`.
