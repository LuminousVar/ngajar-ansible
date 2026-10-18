touch /tmp/.lab-progress
tail -F /tmp/.lab-progress 2>/dev/null &
while [ ! -f /tmp/.lab-ready ] && [ ! -f /tmp/.lab-failed ]; do sleep 2; done
kill %1
if [ -f /tmp/.lab-failed ]; then echo "Setup failed. Check /var/log/lab-*.log, then restart the scenario."; fi
cd /root/lab 2>/dev/null || true
