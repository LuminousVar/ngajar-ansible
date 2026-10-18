# devsec.hardening and verification

```bash
ansible-galaxy collection install -r requirements.yml
ssh -o IdentitiesOnly=yes -i /root/.ssh/lab_ed25519 ansible@node1 sudo sshd -T \
  | grep -E -e '^permitrootlogin' -e '^passwordauth' -e '^x11forwarding'
ansible-playbook lab5-harden.yml --check --diff
ansible-playbook lab5-harden.yml
ansible-playbook lab5-verify.yml
ansible-playbook lab5-harden.yml          # second run should report changed=0
ansible all -m ansible.builtin.ping
```

If you also did Lab 4 in this session, add `-J` to each Ansible command. Click **Check** once the hardening is applied.
