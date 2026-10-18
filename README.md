# ngajar-ansible

Lab repo for a one-day Ansible training. It targets the Killercoda `ubuntu` backend: the Killercoda VM is the control node and three systemd containers are the managed nodes.

| Host | Group | OS | IP |
|---|---|---|---|
| node1, node2 | web | Debian 13 | 10.89.10.11, 10.89.10.12 |
| node3 | db | Rocky 9 | 10.89.10.13 |

## Quick start on Killercoda

Open the Ubuntu playground (https://killercoda.com/playgrounds/scenario/ubuntu), then:

```bash
git clone --depth 1 https://github.com/LuminousVar/ngajar-ansible.git /root/lab
LAB=1 bash /root/lab/killercoda/setup-lab.sh
cat /tmp/.lab-progress
cd /root/lab
```

Every Killercoda session starts on a fresh VM, so clone again each time. Free sessions end after 1 hour.

`setup-lab.sh` installs Ansible, builds the node images, starts the three nodes, writes `known_hosts` and runs a ping smoke test. Progress goes to `/tmp/.lab-progress`, logs to `/var/log/lab-*.log`. Running it again rebuilds the nodes from scratch.

## Installing Ansible with uv

```bash
bash killercoda/install-ansible.sh
```

The script downloads uv 0.13.1 from the GitHub release, checks the sha256, then runs `uv tool install` for ansible-core 2.21 with ansible-lint in the same environment. Executables go to `/usr/local/bin`, so there is no venv to activate. Override versions with `UV_VERSION`, `ANSIBLE_SPEC` and `PYTHON_VERSION`.

```bash
uv tool list --show-with          # ansible-core v2.21.x [with: ansible-lint]
uv tool upgrade ansible-core      # patch upgrades only, stays within >=2.21,<2.22
```

## Labs

| Lab | Topic | Main commands |
|---|---|---|
| 1 | Ad-hoc commands and idempotency | `ansible web -b -m ansible.builtin.apt -a 'name=tree update_cache=true'` (run it twice) |
| 2 | Playbooks, templates, handlers | `ansible-playbook lab2-nginx.yml`, then `curl -s node1:8080` |
| 3 | Roles | `ansible-galaxy role init roles/webserver`, fill it in, then `ansible-playbook lab3-role.yml` |
| 4 | Vault and lint | `ansible-vault create group_vars/web/vault.yml`, `ansible-playbook lab4-vault.yml -J`, `ansible-lint` |
| 5 | SSH hardening | `ansible-galaxy collection install -r requirements.yml`, `ansible-playbook lab5-harden.yml --check --diff`, the same without `--check`, then `ansible-playbook lab5-verify.yml` |

`group_vars/web/vault.yml` is created in Lab 4 and holds one value:

```yaml
vault_app_token: "lab-token-123"
```

Once that file exists, every command that targets the `web` group needs `-J` (`--ask-vault-pass`), ad-hoc ping included, because Ansible decrypts `group_vars` when it loads them.

The Lab 3 solution lives in `solutions/roles/webserver`. `ansible.cfg` looks in `roles/` before `solutions/roles/`, so a participant's own role always wins. Delete `roles/webserver` to fall back to the solution.

## Killercoda scenarios

`scenarios/` holds one scenario per lab. Each one clones this repo and runs `setup-lab.sh` in the background, then checks the result with `verify.sh`. To publish them, connect this repo at https://killercoda.com/creators.

## Fallback without containers

`bootstrap.sh` is for the Killercoda "Kubernetes" playground. It uses `node01` as the managed node when SSH works, and falls back to `localhost` with `ansible_connection=local` when it doesn't.

```bash
bash bootstrap.sh
```

## Layout

```
ansible.cfg, inventory.ini    lab config, points at node1-node3
.ansible-lint                 production profile, mocks the devsec role until Lab 5
lab2-*.yml ... lab5-*.yml     lab playbooks
requirements.yml              devsec.hardening >=11.0.0
group_vars/web/vars.yml       app_token, read from vault_app_token
templates/                    nginx page and vhost templates
solutions/roles/webserver/    Lab 3 solution
killercoda/                   install-ansible.sh, setup-lab.sh, node Containerfiles
scenarios/                    Killercoda scenarios, one per lab
bootstrap.sh                  fallback for the Kubernetes playground
```
