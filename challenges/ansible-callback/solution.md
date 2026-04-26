# Solution: Ansible Callback Plugins

## Approach

Fix the `ansible.cfg` to configure callback plugins correctly.

```ini
[defaults]
stdout_callback = yaml
callbacks_enabled = timer, profile_tasks
```

> Note: In Ansible 2.10+, `callback_whitelist` was renamed to `callbacks_enabled`.

```bash
# Write the fixed config
cat > ~/ansible-project/ansible.cfg << 'EOF'
[defaults]
stdout_callback = yaml
callbacks_enabled = timer, profile_tasks
EOF

# Run the playbook to verify callbacks work
ansible-playbook -i inventory.ini playbook.yml
```

## Why this works

`stdout_callback = yaml` changes output format to YAML (more readable). `callbacks_enabled` activates the timer (shows total time) and profile_tasks (shows per-task timing) plugins.
