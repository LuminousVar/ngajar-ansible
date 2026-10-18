#!/bin/bash
set -eo pipefail
for n in node1 node2; do
  ssh -o BatchMode=yes -o IdentitiesOnly=yes -i /root/.ssh/lab_ed25519 ansible@"$n" command -v tree >/dev/null || exit 1
done
