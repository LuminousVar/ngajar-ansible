#!/bin/bash
set -euo pipefail
git clone --depth 1 https://github.com/LuminousVar/ngajar-ansible.git /root/lab > /var/log/lab-clone.log 2>&1
LAB=4 bash /root/lab/killercoda/setup-lab.sh
