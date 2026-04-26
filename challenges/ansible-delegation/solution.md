# Solution: Ansible Delegation

## What the validator checks

- Playbook had failures
- app.conf not created
- deploy.log not created
- monitoring.txt not created
- app.conf content wrong
- deploy.log content wrong

## Solution

Use `delegate_to:` to run a task on a different host.

```yaml
  tasks:
    - name: Deploy config
      copy:
        content: "version=1.0\n"
        dest: /tmp/delegation-test/app.conf

    - name: Log to monitoring (runs on localhost)
      copy:
        content: "deployed at {{ ansible_date_time.iso8601 }}\n"
        dest: /tmp/delegation-test/monitoring.txt
      delegate_to: localhost
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
