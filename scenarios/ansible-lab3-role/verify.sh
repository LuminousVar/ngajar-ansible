#!/bin/bash
set -eo pipefail
test -f /root/lab/roles/webserver/tasks/main.yml || exit 1
curl -fsS http://node1:8080/ | grep -q 'from role'
