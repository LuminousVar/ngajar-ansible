# Build the webserver role

```bash
ansible-galaxy role init roles/webserver
ansible-lint roles/webserver || true     # the bare skeleton fails lint on purpose
rm -rf roles/webserver/tests roles/webserver/vars roles/webserver/files
# move tasks, handlers and templates out of lab2-nginx.yml into the role
# prefix the variables: webserver_port, webserver_root, webserver_site_title
ansible-lint roles/webserver
ansible-playbook lab3-role.yml
curl -s node1:8080
```

Click **Check** once the page shows the title set by the role.
