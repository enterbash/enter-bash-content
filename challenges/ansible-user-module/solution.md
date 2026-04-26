# Solution: Ansible User Module

## Approach

Use the `user` and `group` modules to manage system users.

```yaml
- name: Manage system users
  hosts: local
  become: yes

  tasks:
    - name: Create deploy group
      group:
        name: deploy
        state: present

    - name: Create deploy user
      user:
        name: deploy        # use "name:", not "username:"
        shell: /bin/bash
        group: deploy
        home: /home/deploy
        create_home: yes
        state: present

    - name: Create appuser
      user:
        name: appuser
        shell: /bin/bash
        groups: deploy
        append: yes
        create_home: yes

    - name: Write user info
      copy:
        content: "users created\n"
        dest: /tmp/users.txt
```

## Why this works

The correct parameter is `name:`, not `username:`. `groups:` (plural) adds supplementary groups. `append: yes` adds to existing groups rather than replacing them.
