#!/usr/bin/env bash
# Builds the Ansible lab on Killercoda (backend imageid: ubuntu, Ubuntu 24.04, 2 GB RAM, Podman preinstalled).
# Control node:  this Killercoda VM, as root.
# Managed nodes: 3 containers running systemd + sshd under rootful Podman, network labnet 10.89.10.0/24.
# Ansible comes from killercoda/install-ansible.sh (uv), with executables in /usr/local/bin.
# Each scenario runs it from background.sh:  LAB=<1-5> bash killercoda/setup-lab.sh
set -Eeuo pipefail

LAB="${LAB:-1}"
LAB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IMG_DIR="$LAB_DIR/killercoda/images"
PROGRESS=/tmp/.lab-progress
READY=/tmp/.lab-ready
FAILED=/tmp/.lab-failed
KEY=/root/.ssh/lab_ed25519
NET=labnet
SUBNET=10.89.10.0/24
# name   image   ip            memory
NODES=(
  "node1 debian 10.89.10.11 256m"
  "node2 debian 10.89.10.12 256m"
  "node3 rocky  10.89.10.13 512m"
)

say() { printf '[%s] %s\n' "$(date +%T)" "$*" >> "$PROGRESS"; }
trap 'say "FAILED at line $LINENO. Details in /var/log/lab-*.log"; touch "$FAILED"' ERR

build_images() {
  install -m 0644 "$KEY.pub" "$IMG_DIR/lab_ed25519.pub"
  podman build -q -t localhost/lab-debian -f "$IMG_DIR/Containerfile.debian" "$IMG_DIR" \
    > /var/log/lab-build-debian.log 2>&1 &
  local p_deb=$!
  podman build -q -t localhost/lab-rocky -f "$IMG_DIR/Containerfile.rocky" "$IMG_DIR" \
    > /var/log/lab-build-rocky.log 2>&1 &
  local p_rocky=$!
  wait "$p_deb"
  wait "$p_rocky"
}

run_nodes() {
  podman network exists "$NET" || podman network create --subnet "$SUBNET" "$NET" >/dev/null
  local n name img ip mem
  for n in "${NODES[@]}"; do
    read -r name img ip mem <<<"$n"
    podman rm -f "$name" >/dev/null 2>&1 || true
    podman run -d --name "$name" --hostname "$name" \
      --network "$NET" --ip "$ip" \
      --memory "$mem" --pids-limit 512 --systemd=always \
      "localhost/lab-$img" >/dev/null
    sed -i "/[[:space:]]$name\$/d" /etc/hosts
    echo "$ip $name" >> /etc/hosts
  done
}

wait_ssh() {
  local n name ok
  for n in "${NODES[@]}"; do
    read -r name _ _ _ <<<"$n"
    ok=0
    for _ in $(seq 1 60); do
      if ssh-keyscan -T 2 -t ed25519 "$name" 2>/dev/null | grep -q ssh-ed25519; then ok=1; break; fi
      sleep 1
    done
    if (( ! ok )); then say "sshd on $name not ready after 60 seconds"; return 1; fi
    ssh-keygen -q -R "$name" >/dev/null 2>&1 || true
    ssh-keyscan -t ed25519 "$name" 2>/dev/null >> /root/.ssh/known_hosts
  done
}

write_inventory() {
  cat > "$LAB_DIR/inventory.ini" <<'EOF'
[web]
node1
node2

[db]
node3

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=/root/.ssh/lab_ed25519
EOF
}

: > "$PROGRESS"
rm -f "$READY" "$FAILED"
say "Lab $LAB setup started"
install -d -m 0700 /root/.ssh
[[ -f $KEY ]] || ssh-keygen -q -t ed25519 -N '' -C ansible-lab -f "$KEY"

# Install uv + ansible-core while the images build. The subshell drops the ERR trap,
# so a failed install is reported once, by the wait below.
( trap - ERR; bash "$LAB_DIR/killercoda/install-ansible.sh" ) > /var/log/lab-ansible-install.log 2>&1 &
p_ansible=$!

say "Building node images: Debian 13 and Rocky 9 (in parallel)"
build_images
say "Starting node1, node2 (Debian) and node3 (Rocky) on network $NET"
run_nodes
say "Waiting for sshd on all three nodes"
wait_ssh
say "Waiting for the uv and ansible-core install"
wait "$p_ansible"
write_inventory
say "Smoke test: ansible all -m ping"
cd "$LAB_DIR"
ansible all -m ansible.builtin.ping >> /var/log/lab-smoke.log 2>&1
say "Smoke test passed: node1, node2 and node3 answered pong"
touch "$READY"
say "Lab ready. cd /root/lab"
