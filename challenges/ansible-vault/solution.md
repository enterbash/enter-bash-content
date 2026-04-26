# Solution: Ansible Vault

## Approach

Create a vault password file, encrypt secrets with `ansible-vault`, and reference them in the playbook.

```bash
# Create vault password file
echo "mysecretpassword" > ~/.vault_pass
chmod 600 ~/.vault_pass

# Create and encrypt secrets file
ansible-vault create --vault-password-file ~/.vault_pass secrets.yml
# Add: db_password: supersecret123
# Add: api_key: abc123xyz

# Or encrypt an existing file
ansible-vault encrypt --vault-password-file ~/.vault_pass secrets.yml
```

Playbook using vault:
```yaml
- name: Use vault secrets
  hosts: local
  vars_files:
    - secrets.yml

  tasks:
    - name: Write config with secret
      copy:
        content: "db_pass={{ db_password }}\n"
        dest: /tmp/app-secret.conf
```

Run with vault:
```bash
ansible-playbook -i inventory.ini playbook.yml --vault-password-file ~/.vault_pass
```

## Why this works

`ansible-vault` encrypts YAML files using AES-256. The vault password file avoids interactive prompts. Never commit unencrypted secrets.
