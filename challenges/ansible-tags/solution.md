# Solution: Ansible Tags

## What the validator checks

- 'setup' tag not found
- 'config' tag not found
- Setup tags failed
- /tmp/tagapp not created by setup tag
- Full playbook had failures
- app.conf not created
- log.conf not created

## Solution

Add `tags:` to tasks to allow selective execution.

```yaml
  tasks:
    - name: Install packages
      apt:
        name: curl
        state: present
      tags: [packages, install]

    - name: Deploy config
      copy:
        content: "app=myapp\n"
        dest: /tmp/app.conf
      tags: [config, deploy]
```

Run with: `ansible-playbook playbook.yml --tags config`

```bash
ansible-playbook -i inventory.ini playbook.yml
```
