# Solution: Fix Ansible Playbook

## What the validator checks

- Playbook had failures

## Solution

Fix the broken playbook so it runs without errors.

```bash
# Check syntax first
ansible-playbook -i inventory.ini playbook.yml --syntax-check

# Run with verbose output to see what's failing
ansible-playbook -i inventory.ini playbook.yml -v
```

Common issues to look for:
- `src:` and `content:` used together in `copy` module (mutually exclusive)
- Missing `dest:` in copy tasks
- Wrong indentation
- Invalid module parameter names

```bash
ansible-playbook -i inventory.ini playbook.yml
```
