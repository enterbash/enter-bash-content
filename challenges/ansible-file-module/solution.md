# Solution: Ansible File Module

## Approach

Review the playbook and fix the issues so it runs successfully.

```bash
# Check syntax first
ansible-playbook -i inventory.ini playbook.yml --syntax-check

# Run with verbose output to see what's happening
ansible-playbook -i inventory.ini playbook.yml -v
```

## Key concepts

- Always run `--syntax-check` before executing
- Use `-v`, `-vv`, or `-vvv` for increasing verbosity
- Check `failed=0` in the PLAY RECAP to confirm success
