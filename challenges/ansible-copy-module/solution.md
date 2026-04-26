# Solution: Ansible Copy Module

## Approach

The `copy` module has two modes: `src:` (copy a file) and `content:` (write inline text). They are mutually exclusive. Fix each task to use the right one.

```yaml
- name: Copy config from source
  copy:
    src: source_config.txt      # copies the file — db.conf gets "host=localhost"
    dest: /tmp/copymod/db.conf
    mode: "0644"

- name: Create app config with content
  copy:
    content: |                  # inline content
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

## Why this works

`src:` and `content:` are mutually exclusive — using both causes Ansible to fail. The validation checks that `db.conf` contains `host=localhost` (from `source_config.txt`) and `app.conf` contains `name=myapp` (from inline content).
