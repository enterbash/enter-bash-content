# Solution: Ansible Vault

## What the validator checks

- .vault_pass file missing
- secrets.yml is not encrypted
- Playbook had failures
- db.conf not created
- api.conf not created
- db_password not decrypted
- api_key not decrypted

## Solution

Create a vault password file, encrypt secrets, and reference them in the playbook.

```bash
# Create vault password file
echo "mysecretpassword" > ~/.vault_pass
chmod 600 ~/.vault_pass

# Create encrypted secrets file
ansible-vault create --vault-password-file ~/.vault_pass secrets.yml
# Add: db_password: supersecret123
# Add: api_key: abc123xyz
```

```yaml
- name: Use vault secrets
  hosts: local
  vars_files:
    - secrets.yml
  tasks:
    - name: Write config
      copy:
        content: "db_pass={{ db_password }}\n"
        dest: /tmp/app-secret.conf
```

Run: `ansible-playbook -i inventory.ini playbook.yml --vault-password-file ~/.vault_pass`

```bash
ansible-playbook -i inventory.ini playbook.yml
```
