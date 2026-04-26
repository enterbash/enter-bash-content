# Solution: Ansible set_fact Module

## Approach

Use `set_fact:` to create or transform variables during playbook execution.

```yaml
- name: Use set_fact
  hosts: local
  become: yes

  tasks:
    - name: Get current date
      command: date +%Y-%m-%d
      register: date_output

    - name: Set derived facts
      set_fact:
        deploy_date: "{{ date_output.stdout }}"
        app_version: "2.1.0"
        deploy_tag: "v2.1.0-{{ date_output.stdout }}"

    - name: Write deployment info
      copy:
        content: "version={{ app_version }}\ndate={{ deploy_date }}\ntag={{ deploy_tag }}\n"
        dest: /tmp/deploy_info.txt
```

## Why this works

`set_fact:` creates host-scoped variables that persist for the rest of the play. Useful for computed values or transforming registered output.
