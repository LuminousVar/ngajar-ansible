#!/bin/bash
set -eo pipefail
for n in node1 node2; do
  curl -fsS "http://$n:8080/" | grep -q 'Ansible Training' || exit 1
done
