# Solution: Ansible Service Module

## Approach

Use the `command` module to manage the fake service (no systemd in container).

```yaml
- name: Manage application service
  hosts: local
  become: yes

  tasks:
    - name: Create service config directory
      file:
        path: /tmp/myservice-conf
        state: directory

    - name: Write service config
      copy:
        content: |
          [service]
          name=myservice
          port=9090
          workers=4
        dest: /tmp/myservice-conf/service.conf
        mode: "0644"

    - name: Start the service
      command: myservice start
      register: start_result

    - name: Check service status
      command: myservice status
      register: service_status

    - name: Write status to file
      copy:
        content: "{{ service_status.stdout }}\n"
        dest: /tmp/myservice-conf/status.txt
```

## Why this works

In a container without systemd, use `command:` to run the service script directly. The `myservice` script was created by setup.sh at `/usr/local/bin/myservice`.
