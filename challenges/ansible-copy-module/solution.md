# Solution: Ansible Copy Module

## What the validator checks

- Playbook had failures
- db.conf not created
- app.conf not created
- readme.txt not created
- db.conf should have source content
- app.conf content wrong

## Solution

The `copy` module uses either `src:` (copy a file) or `content:` (write inline text) — never both.

```yaml
- name: Copy config from source
  copy:
    src: source_config.txt      # copies the file → db.conf gets "host=localhost"
    dest: /tmp/copymod/db.conf
    mode: "0644"

- name: Create app config with content
  copy:
    content: |
      [app]
      name=myapp
      debug=false
    dest: /tmp/copymod/app.conf
    mode: "0644"

- name: Create readme file
  copy:
    src: source_config.txt
    dest: /tmp/copymod/readme.txt
    mode: "0644"
    owner: root
```

The validator checks that `db.conf` contains `host=localhost` (from `source_config.txt`) and `app.conf` contains `name=myapp` (from inline content).

```bash
ansible-playbook -i inventory.ini playbook.yml
```
