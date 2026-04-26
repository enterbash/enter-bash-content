# Solution: Ansible Serial (Rolling Updates)

## Approach

Add `serial:` to the play to control how many hosts are updated at once (rolling deployment).

```yaml
- name: Rolling deployment
  hosts: webservers
  become: yes
  serial: 1          # update 1 host at a time (or use "50%" for percentage)

  tasks:
    - name: Create deploy directory
      file:
        path: /tmp/serial-deploy
        state: directory

    - name: Deploy application
      copy:
        content: |
          version=2.0
          host={{ inventory_hostname }}
        dest: /tmp/serial-deploy/app.conf

    - name: Write deploy marker
      copy:
        content: "deployed\n"
        dest: /tmp/serial-deploy/deployed.txt
```

## Why this works

`serial: 1` processes one host at a time. `serial: "50%"` does half the hosts at once. This prevents all hosts from being updated simultaneously, enabling zero-downtime deployments.
