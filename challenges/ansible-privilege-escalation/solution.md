# Solution: Ansible Privilege Escalation

## What the validator checks

- Playbook had failures
- root_user.txt not created
- deploy_user.txt not created
- status.txt not created
- root task not running as root
- deploy task not running as deploy
- 'become:' not found in playbook

## Solution

Use `become: yes` and `become_user:` — never the deprecated `sudo:`.

```yaml
- name: Privilege escalation
  hosts: local
  become: yes          # become root by default
  tasks:
    - name: Create root-owned file
      copy:
        content: "root owned\n"
        dest: /tmp/priv-test/root_file.txt

    - name: Write as deploy user
      copy:
        content: "deploy user\n"
        dest: /tmp/priv-test/deploy_file.txt
      become_user: deploy
      become: yes
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
