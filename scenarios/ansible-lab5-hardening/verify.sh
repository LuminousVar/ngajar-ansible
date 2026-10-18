#!/bin/bash
set -eo pipefail
for n in node1 node2; do
  ssh -o BatchMode=yes -o IdentitiesOnly=yes -i /root/.ssh/lab_ed25519 ansible@"$n" sudo sshd -T \
    | grep -qx 'passwordauthentication no' || exit 1
done
