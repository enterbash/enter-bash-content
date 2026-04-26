# Solution: Ansible set_fact Module

## What the validator checks

- Playbook had failures
- deploy_info.txt not created
- app_id not set correctly
- deploy_time not set
- deploy_time is empty

## Solution

Use `set_fact:` to create computed variables during playbook execution.

```yaml
  tasks:
    - name: Get date
      command: date +%Y-%m-%d
      register: date_output

    - name: Set derived facts
      set_fact:
        deploy_date: "{{ date_output.stdout }}"
        app_version: "2.1.0"
        deploy_tag: "v2.1.0-{{ date_output.stdout }}"

    - name: Write deployment info
      copy:
        content: "version={{ app_version }}\ndate={{ deploy_date }}\n"
        dest: /tmp/deploy_info.txt
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
