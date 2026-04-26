# Solution: Ansible Handlers

## Approach

Handlers are tasks that only run when notified. Define them in a `handlers:` section and use `notify:` in tasks.

```yaml
- name: Deploy application
  hosts: local
  become: yes
  handlers:
    - name: restart myapp
      copy:
        content: "restarted\n"
        dest: /tmp/myapp/restart.log

    - name: reload config
      copy:
        content: "reloaded\n"
        dest: /tmp/myapp/reload.log

  tasks:
    - name: Create app directory
      file:
        path: /tmp/myapp
        state: directory

    - name: Deploy app config
      copy:
        content: "app_port=8080\n"
        dest: /tmp/myapp/app.conf
      notify: restart myapp

    - name: Deploy logging config
      copy:
        content: "log_level=INFO\n"
        dest: /tmp/myapp/logging.conf
      notify: reload config
```

## Why this works

Handlers run once at the end of a play, even if notified multiple times. They only run if the notifying task reports `changed`.
