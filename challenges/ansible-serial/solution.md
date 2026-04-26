# Solution: Ansible Serial (Rolling Updates)

## What the validator checks

- serial not defined in playbook
- Playbook had failures
- app.conf not created
- deployed.txt not created
- version wrong in app.conf

## Solution

Add `serial:` to the play to control rolling deployment batch size.

```yaml
- name: Rolling deployment
  hosts: webservers
  become: yes
  serial: 1          # update 1 host at a time; use "50%" for percentage
  tasks:
    - name: Deploy app
      copy:
        content: "version=2.0\n"
        dest: /tmp/serial-deploy/app.conf
    - name: Write marker
      copy:
        content: "deployed\n"
        dest: /tmp/serial-deploy/deployed.txt
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
