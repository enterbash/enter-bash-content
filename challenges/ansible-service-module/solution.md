# Solution: Ansible Service Module

## What the validator checks

- Playbook had failures
- service.conf not created
- service not started (no PID file)
- status.txt not created
- service not reporting running

## Solution

Use the `command` module to manage the fake service (no systemd in container).

```yaml
  tasks:
    - name: Create service config
      copy:
        content: |
          [service]
          name=myservice
          port=9090
        dest: /tmp/myservice-conf/service.conf
        mode: "0644"

    - name: Start the service
      command: myservice start
      register: start_result

    - name: Check status
      command: myservice status
      register: service_status

    - name: Write status
      copy:
        content: "{{ service_status.stdout }}\n"
        dest: /tmp/myservice-conf/status.txt
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
