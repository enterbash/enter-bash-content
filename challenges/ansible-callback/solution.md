# Solution: Ansible Callback Plugins

## What the validator checks

- stdout_callback not configured
- yaml callback not set
- callback_whitelist/callbacks_enabled not configured
- Playbook had failures
- done.txt not created

## Solution

Fix `ansible.cfg` — use `callbacks_enabled` (not the deprecated `callback_whitelist`).

```ini
[defaults]
stdout_callback = yaml
callbacks_enabled = timer, profile_tasks
```

```bash
cat > ~/ansible-project/ansible.cfg << 'EOF'
[defaults]
stdout_callback = yaml
callbacks_enabled = timer, profile_tasks
EOF
```

```bash
ansible-playbook -i inventory.ini playbook.yml
```
