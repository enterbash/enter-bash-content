# Solution: Ansible Tags

## Approach

Add `tags:` to tasks to allow selective execution with `--tags` or `--skip-tags`.

```yaml
- name: Deploy application
  hosts: local
  become: yes

  tasks:
    - name: Install packages
      apt:
        name: curl
        state: present
      tags: [packages, install]

    - name: Deploy config
      copy:
        content: "app=myapp\n"
        dest: /tmp/app.conf
      tags: [config, deploy]

    - name: Run health check
      command: echo "healthy"
      tags: [health, verify]
```

Run specific tags:
```bash
ansible-playbook -i inventory.ini playbook.yml --tags config
ansible-playbook -i inventory.ini playbook.yml --skip-tags packages
```

## Why this works

Tags let you run subsets of a playbook. A task can have multiple tags. `always` and `never` are special tags.
