# Ad-hoc commands, facts and idempotency

Run everything from `/root/lab`:

```bash
ansible-inventory --graph
ansible all -m ansible.builtin.ping
ansible web -m ansible.builtin.setup -a 'filter=ansible_distribution*'

# run this TWICE and compare CHANGED with SUCCESS
ansible web -b -m ansible.builtin.apt -a 'name=tree update_cache=true'

ansible all -b -m ansible.builtin.package -a 'name=tree'
ansible all -m ansible.builtin.command -a 'tree -L 1 /etc/ssh'
```

Click **Check** once `tree` is installed on node1 and node2.
