#!/usr/bin/env bash
# Fallback lab for the Killercoda "Kubernetes" playground (2 nodes), no containers needed.
# controlplane is the control node, node01 is the managed node.
# Free Killercoda sessions end after 1 hour, so run this again in each new session.
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "[..] installing uv, ansible-core and ansible-lint"
  bash killercoda/install-ansible.sh
fi

if ssh -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new node01 true 2>/dev/null; then
  cat > inventory.ini <<'EOF'
[web]
node01 ansible_user=root
EOF
  echo "[ok] node01 is reachable over SSH, inventory points to node01"
else
  cat > inventory.ini <<'EOF'
[web]
localhost ansible_connection=local
EOF
  echo "[warn] SSH to node01 failed, falling back to localhost (ansible_connection=local)"
fi

ansible --version | head -n 1
ansible all -m ansible.builtin.ping
