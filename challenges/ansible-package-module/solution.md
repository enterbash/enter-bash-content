# Solution: Ansible Package Module

## Approach

Use the `apt` module with correct state values to install packages.

```yaml
- name: Install required packages
  hosts: local
  become: yes

  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Install curl
      apt:
        name: curl
        state: present      # not "installed" — that's invalid

    - name: Install jq
      apt:
        name: jq
        state: present      # not "latest" unless you want upgrades

    - name: Install tree
      apt:
        name: tree          # use "name:", not "pkg:"
        state: present

    - name: Write version info
      copy:
        content: "packages installed successfully\n"
        dest: /tmp/packages_installed.txt
```

## Why this works

Valid `state` values for `apt`: `present`, `absent`, `latest`, `build-dep`. `installed` is not valid. Use `name:` not the deprecated `pkg:` alias.
