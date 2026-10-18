# Encrypted secrets and a quality gate

```bash
export EDITOR=nano
ansible-vault create group_vars/web/vault.yml
#   file content:  vault_app_token: "lab-token-123"
head -1 group_vars/web/vault.yml
ansible-playbook lab4-vault.yml -J
grep -c lab-token-123 ansible.log        # should print 0
ansible-lint
```

Click **Check** once the token is on node1.
