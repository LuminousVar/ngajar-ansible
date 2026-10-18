# Deploy nginx to the web group

```bash
cat lab2-nginx.yml
ansible-playbook lab2-nginx.yml
curl -s node1:8080
ansible-playbook lab2-nginx.yml          # second run should report changed=0
ansible-playbook lab2-nginx.yml --check --diff -e 'site_title="Hello Class"'
```

Click **Check** once node1 and node2 serve the page on port 8080.
