# Solution: Ansible Privilege Escalation

## Approach

Use `become:` and `become_user:` for privilege escalation instead of the deprecated `sudo:`.

```yaml
- name: Privilege escalation demo
  hosts: local
  become: yes          # become root by default

  tasks:
    - name: Create root-owned directory
      file:
        path: /tmp/priv-test
        state: directory
        owner: root
        mode: "0755"

    - name: Write root info
      shell: whoami > /tmp/priv-test/root_user.txt

    - name: Create deploy directory
      file:
        path: /tmp/priv-test/deploy
        state: directory
        owner: deploy
        mode: "0755"

    - name: Write deploy user info
      shell: whoami > /tmp/priv-test/deploy_user.txt
      become_user: deploy    # switch to deploy user for this task
      become: yes

    - name: Write status
      copy:
        content: "privilege escalation configured\n"
        dest: /tmp/priv-test/status.txt
```

## Why this works

`become: yes` at play level makes all tasks run as root. `become_user: deploy` on a specific task overrides to run as that user. Never use the deprecated `sudo:` directive.
