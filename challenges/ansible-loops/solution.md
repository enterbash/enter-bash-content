# Solution: Ansible Loops

## What the validator checks

- Playbook had failures
- /tmp/apps/$app not created
- /tmp/apps/$app/config.txt not created
- /tmp/apps/$app/logs not created
- frontend port wrong
- backend port wrong

## Solution

Use `loop:` to iterate over a list. Access the current item with `item`.

```yaml
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

```bash
ansible-playbook -i inventory.ini playbook.yml
```
