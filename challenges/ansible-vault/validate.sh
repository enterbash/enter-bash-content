#!/bin/bash
cd ~/ansible-project

# Check vault password file exists
[ -f .vault_pass ] || { echo "FAIL: .vault_pass file missing"; exit 1; }

# Check secrets.yml is encrypted
head -1 secrets.yml | grep -q "^\$ANSIBLE_VAULT" || { echo "FAIL: secrets.yml is not encrypted"; exit 1; }

# Run playbook with vault
ansible-playbook -i inventory.ini playbook.yml --vault-password-file .vault_pass --syntax-check > /dev/null 2>&1

RESULT=$(ansible-playbook -i inventory.ini playbook.yml --vault-password-file .vault_pass 2>&1)
if ! echo "$RESULT" | grep -q "failed=0"; then
  echo "FAIL: Playbook had failures"
  exit 1
fi

[ -f /tmp/secrets/db.conf ] || { echo "FAIL: db.conf not created"; exit 1; }
[ -f /tmp/secrets/api.conf ] || { echo "FAIL: api.conf not created"; exit 1; }
grep -q "supersecret" /tmp/secrets/db.conf || { echo "FAIL: db_password not decrypted"; exit 1; }
grep -q "abc123xyz" /tmp/secrets/api.conf || { echo "FAIL: api_key not decrypted"; exit 1; }

echo "PASS: Vault secrets working correctly"
exit 0
