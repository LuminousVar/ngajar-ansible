#!/bin/bash
set -eo pipefail
# shellcheck disable=SC2016  # literal $ANSIBLE_VAULT
head -1 /root/lab/group_vars/web/vault.yml | grep -qF '$ANSIBLE_VAULT;' || exit 1
ssh -o BatchMode=yes -o IdentitiesOnly=yes -i /root/.ssh/lab_ed25519 ansible@node1 sudo test -s /etc/demo-app/token
