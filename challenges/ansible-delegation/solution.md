# Solution: Ansible Delegation

## Approach

Use `delegate_to:` to run a task on a different host than the current target.

```yaml
- name: Deploy with delegation
  hosts: webservers
  become: yes

  tasks:
    - name: Deploy app config
      copy:
        content: "[app]\nversion=1.0\n"
        dest: /tmp/delegation-test/app.conf

    - name: Log deployment to monitoring server
      copy:
        content: "deployed to {{ inventory_hostname }} at {{ ansible_date_time.iso8601 }}\n"
        dest: /tmp/delegation-test/monitoring.txt
      delegate_to: localhost    # run this task on localhost instead

    - name: Write deploy log
      copy:
        content: "deployment complete\n"
        dest: /tmp/delegation-test/deploy.log
```

## Why this works

`delegate_to:` redirects a specific task to run on a different host. The task still uses variables from the current host (`inventory_hostname`), but executes on the delegated host.
